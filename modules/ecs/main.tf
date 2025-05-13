# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

# IAM Role for ECS Node
data "aws_iam_policy_document" "ecs_node_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_node_role" {
  name_prefix        = var.iam_role_prefix
  assume_role_policy = data.aws_iam_policy_document.ecs_node_doc.json
}

resource "aws_iam_role_policy_attachment" "ecs_node_role_policy" {
  role       = aws_iam_role.ecs_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_node" {
  name_prefix = var.iam_profile_prefix
  path        = "/ecs/instance/"
  role        = aws_iam_role.ecs_node_role.name
}

# Security Group for ECS Nodes
resource "aws_security_group" "ecs_node_sg" {
  name_prefix = var.sg_prefix
  vpc_id      = var.vpc_id  # Using VPC module output for VPC ID

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Fetch the ECS optimized AMI
data "aws_ssm_parameter" "ecs_node_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# Launch Template for ECS EC2 Instances
resource "aws_launch_template" "ecs_ec2" {
  name_prefix            = var.launch_template_prefix
  image_id               = data.aws_ssm_parameter.ecs_node_ami.value
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ecs_node_sg.id]

  iam_instance_profile { arn = aws_iam_instance_profile.ecs_node.arn }
  monitoring { enabled = true }

  user_data = base64encode(<<-EOF
      #!/bin/bash
      echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config;
    EOF
  )
}

# Auto Scaling Group for ECS EC2 Instances
resource "aws_autoscaling_group" "ecs" {
  name_prefix               = var.asg_prefix
  vpc_zone_identifier       = var.private_subnet_ids  # Use a list of private/public subnet IDs
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  health_check_grace_period = 0
  health_check_type         = "EC2"
  protect_from_scale_in     = false

  launch_template {
    id      = aws_launch_template.ecs_ec2.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}

# ECS Capacity Provider
resource "aws_ecs_capacity_provider" "main" {
  name = var.capacity_provider_name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = var.max_scaling_step_size
      minimum_scaling_step_size = var.min_scaling_step_size
      status                    = "ENABLED"
      target_capacity           = var.target_capacity
    }
  }
}

# Associate Capacity Provider with ECS Cluster
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = [aws_ecs_capacity_provider.main.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    base              = var.capacity_provider_base
    weight            = 100
  }
}

##########################
# ECS Task Role
##########################

resource "aws_iam_role" "ecs_task_role" {
  name_prefix        = var.ecs_task_role_name_prefix
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

##########################
# ECS Execution Role
##########################

resource "aws_iam_role" "ecs_exec_role" {
  name_prefix        = var.ecs_exec_role_name_prefix
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

# Attach ECS execution policy
resource "aws_iam_role_policy_attachment" "ecs_exec_role_policy" {
  role       = aws_iam_role.ecs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "ecs_cloudwatch_log_group" {
  name              = var.ecs_log_group
  retention_in_days = 14
}


resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = var.task_family
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_exec_role.arn
  network_mode             = var.network_mode
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  requires_compatibilities = var.compatibilities

  container_definitions = jsonencode([
    {
      name         = var.container_name
      image        = "${var.repository_url}:latest"
      essential    = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port
        }
      ]
      environment = var.container_environment
    }
  ])
}





#######################################################################################################

# SECURITY GROUP FOR ECS TASK
resource "aws_security_group" "ecs_task" {
  name_prefix = var.ecs_task_security_group
  description = "Allow all traffic within the VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SECURITY GROUP FOR HTTP ACCESS TO ALB
resource "aws_security_group" "http" {
  name_prefix = var.alb_security_name
  description = "Allow all HTTP/HTTPS traffic from public"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = [80, 443]
    content {
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# APPLICATION LOAD BALANCER
resource "aws_lb" "main" {
  name               = var.loadbalancer_name
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.http.id]
}

# TARGET GROUP
resource "aws_lb_target_group" "app" {
  name_prefix = var.alb_target_group_name
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  port        = 80
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/"
    port                = 80
    matcher             = "200"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

# ALB LISTENER
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.id
  }
}

# ECS SERVICE
resource "aws_ecs_service" "app" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = var.ecs_service_min_capacity
  launch_type     = "EC2"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_task.id]
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [aws_lb_listener.http]
}

# AUTOSCALING TARGET
resource "aws_appautoscaling_target" "ecs" {
  service_namespace  = var.ecs_autoscaling_target
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.ecs_service_min_capacity
  max_capacity       = var.ecs_service_max_capacity
}

# AUTOSCALING POLICY (CPU)
resource "aws_appautoscaling_policy" "cpu_scale_out" {
  name               = var.scaling_policy_name
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}


