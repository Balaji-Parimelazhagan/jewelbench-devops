# ECS-optimized AMI
data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# IAM Role for ECS EC2 instances
resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.name}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.name}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = var.name
}

# Security Group
resource "aws_security_group" "ecs_sg" {
  name_prefix = "${var.name}-ecs"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load Balancer
resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.ecs_sg.id]
}

resource "aws_lb_target_group" "this" {
  name        = "${var.name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.container_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# Launch Template
resource "aws_launch_template" "gpu" {
  name_prefix   = "${var.name}-lt"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = "t3.medium"
  key_name      = var.key_name

  iam_instance_profile { name = aws_iam_instance_profile.ecs_instance_profile.name }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.this.name} >> /etc/ecs/ecs.config
  EOF
  )

  network_interfaces {
    security_groups = [aws_security_group.ecs_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "${var.name}-gpu" }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "gpu" {
  name                      = "${var.name}-asg"
  max_size                  = 5
  min_size                  = 0
  desired_capacity          = 0
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "EC2"
  protect_from_scale_in     = true

  launch_template {
    id      = aws_launch_template.gpu.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-gpu"
    propagate_at_launch = true
  }
}

# ECS Capacity Provider
resource "aws_ecs_capacity_provider" "gpu_cp" {
  name = "${var.name}-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.gpu.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = [aws_ecs_capacity_provider.gpu_cp.name]
}

# ECS Task Definition
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name}-task"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "256"
  network_mode             = "bridge"

  container_definitions = jsonencode([{
    name      = var.name,
    image     = var.image,
    essential = true,
    portMappings = [{
      containerPort = var.container_port,
      hostPort      = var.container_port
    }]
  }])
}

# ECS Service
resource "aws_ecs_service" "this" {
  name            = "${var.name}-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 0

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.gpu_cp.name
    weight            = 1
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.name
    container_port   = var.container_port
  }
}

# Application Auto Scaling Target
resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = 5
  min_capacity       = 0
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Target Tracking Scaling Policy for ECS based on SQS messages
resource "aws_appautoscaling_policy" "sqs_target_tracking" {
  name               = "${var.name}-target-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "SQSQueueMessagesVisible"
      resource_label         = "${var.sqs_name}-${var.aws_region}"
    }

    target_value       = 5
    scale_in_cooldown  = 120
    scale_out_cooldown = 60
  }
}

# S3 Bucket with folder and SQS notification
resource "aws_s3_bucket" "this" {
  bucket        = "${var.name}-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_s3_to_sqs" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "sqs:SendMessage",
      Resource  = var.sqs_arn,
      Condition = {
        ArnLike = {
          "aws:SourceArn": aws_s3_bucket.this.arn
        }
      }
    }]
  })
}

resource "aws_s3_bucket_notification" "sqs_trigger" {
  bucket = aws_s3_bucket.this.id

  queue {
    queue_arn     = var.sqs_arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "uploads/"
  }

  depends_on = [aws_s3_bucket_policy.allow_s3_to_sqs]
}
