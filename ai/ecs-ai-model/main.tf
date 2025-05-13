data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.name}-ecs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}


resource "aws_iam_role_policy_attachment" "ecs_rds_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}


resource "aws_iam_role_policy_attachment" "ecs_redis_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElastiCacheFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_cloudwatch_logs_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_s3_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


resource "aws_iam_role_policy_attachment" "ecs_dynamodb_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Attach policy for Secrets Manager (Allow EC2 instances to access secrets)
resource "aws_iam_role_policy_attachment" "ecs_secretsmanager_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "ecs_cloudwatch_metrics_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}


resource "aws_iam_role_policy_attachment" "ecs_ssm_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_ecr_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}




resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.name}-ecs-profile"
  role = aws_iam_role.ecs_instance_role.name
}



# --------------------
# ECS Cluster
# --------------------
resource "aws_ecs_cluster" "this" {
  name = var.name
}

# --------------------
# Security Group
# --------------------
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

# --------------------
# ALB and Target Group
# --------------------
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

# --------------------
# Launch Template and ASG
# --------------------
resource "aws_launch_template" "gpu" {
  name_prefix   = "${var.name}-lt"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.instance_type
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

resource "aws_autoscaling_group" "gpu" {
  name                      = "${var.name}-asg"
  max_size                  = var.max_capacity
  min_size                  = var.min_capacity
  desired_capacity          = 0
  vpc_zone_identifier       = var.private_subnet_ids
  protect_from_scale_in     = true
  health_check_type         = "EC2"

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

# --------------------
# Capacity Provider
# --------------------
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

# --------------------
# ECS Task and Service
# --------------------
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name}-task"
  requires_compatibilities = ["EC2"]
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "bridge"

  container_definitions = jsonencode([{
    name      = var.name,
    image     = var.image,
    essential = true,
    portMappings = [{
      containerPort = var.container_port,
      hostPort      = var.container_port
    }],
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = "/ecs/${var.name}",
        awslogs-region        = var.region,
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "this" {
  name            = "${var.name}-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1

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

# --------------------
# Application Auto Scaling
# --------------------
resource "aws_appautoscaling_target" "ecs_service" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}



resource "aws_appautoscaling_policy" "scale_up" {
  name               = "${var.name}-scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_service.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      scaling_adjustment          = 1
      metric_interval_lower_bound = 5
      metric_interval_upper_bound = 10
    }

    step_adjustment {
      scaling_adjustment          = 2
      metric_interval_lower_bound = 10
      metric_interval_upper_bound = 15
    }

    step_adjustment {
      scaling_adjustment          = 3
      metric_interval_lower_bound = 15
    }
  }
}

# resource "aws_appautoscaling_policy" "scale_up" {
#   count              = 3
#   name               = "${var.name}-scale-up-${count.index + 1}"
#   policy_type        = "StepScaling"
#   resource_id        = aws_appautoscaling_target.ecs_service.resource_id
#   scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.ecs_service.service_namespace

#   step_scaling_policy_configuration {
#     adjustment_type         = "ChangeInCapacity"
#     cooldown                = 60
#     metric_aggregation_type = "Average"

#     step_adjustment {
#       scaling_adjustment          = count.index + 1
#       metric_interval_lower_bound = 0
#     }
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "scale_up" {
#   count               = 3
#   alarm_name          = "${var.name}-scale-up-alarm-${count.index + 1}"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = 1
#   metric_name         = "ApproximateNumberOfMessagesVisible"
#   namespace           = "AWS/SQS"
#   period              = 60
#   statistic           = "Average"
#   threshold           = (count.index + 1) * 5
#   alarm_actions       = [aws_appautoscaling_policy.scale_up[count.index].arn]

#   dimensions = {
#     QueueName = var.sqs_name
#   }
# }

resource "aws_appautoscaling_policy" "scale_down" {
  name               = "${var.name}-scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_service.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      scaling_adjustment          = -1
      metric_interval_upper_bound = 0
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_name          = "${var.name}-scale-down-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  alarm_actions       = [aws_appautoscaling_policy.scale_down.arn]

  dimensions = {
    QueueName = var.sqs_name
  }
}
