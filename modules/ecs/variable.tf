variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "iam_role_prefix" {
  description = "Prefix for ECS Node IAM role"
  type        = string
}

variable "iam_profile_prefix" {
  description = "Prefix for ECS Node IAM instance profile"
  type        = string
}

variable "sg_prefix" {
  description = "Prefix for ECS node security group"
  type        = string
}

variable "launch_template_prefix" {
  description = "Prefix for ECS EC2 launch template"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for ECS node"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "asg_prefix" {
  description = "Prefix for Auto Scaling Group"
  type        = string
}

variable "asg_min_size" {
  description = "Minimum size for Auto Scaling Group"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum size for Auto Scaling Group"
  type        = number
}

variable "capacity_provider_name" {
  description = "Name of the ECS Capacity Provider"
  type        = string
}

variable "max_scaling_step_size" {
  description = "Maximum scaling step size for ECS Capacity Provider"
  type        = number
}

variable "min_scaling_step_size" {
  description = "Minimum scaling step size for ECS Capacity Provider"
  type        = number
}

variable "target_capacity" {
  description = "Target capacity for ECS Capacity Provider"
  type        = number
}

variable "capacity_provider_base" {
  description = "Base value for ECS Capacity Provider Strategy"
  type        = number
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}


variable "ecs_task_role_name_prefix" {
  description = "Prefix for ECS task role"
  type        = string
}

variable "ecs_exec_role_name_prefix" {
  description = "Prefix for ECS execution role"
  type        = string
}

variable "ecs_log_group" {
  description = "Prefix for ECS execution role"
  type        = string
}


variable "task_family" {
  type    = string
}


variable "network_mode" {
  type    = string
}

variable "task_cpu" {
  type    = number
}

variable "task_memory" {
  type    = number
}

variable "compatibilities" {
  type    = list(string)

}

variable "container_name" {
  type    = string
}

variable "container_port" {
  type    = number
}

variable "host_port" {
  type    = number
}

variable "container_environment" {
  type = list(object({
    name  = string
    value = string
  }))
}

variable "repository_url"{
  type    = string
}

variable "region" {
  type=string
  
}


variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}


# Security Groups
variable "ecs_task_security_group" {
  description = "Prefix for ECS Task Security Group"
  type        = string
}

variable "alb_security_name" {
  description = "Prefix for ALB Security Group"
  type        = string
}

# ALB
variable "loadbalancer_name" {
  description = "Name of the ALB"
  type        = string
}

variable "alb_target_group_name" {
  description = "Prefix for the target group name"
  type        = string
}

# ECS Service
variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

# Auto Scaling
variable "ecs_autoscaling_target" {
  description = "ECS service namespace (should be 'ecs')"
  type        = string
  default     = "ecs"
}

variable "ecs_service_min_capacity" {
  description = "Minimum ECS service task count"
  type        = number
}

variable "ecs_service_max_capacity" {
  description = "Maximum ECS service task count"
  type        = number
}

variable "scaling_policy_name" {
  description = "Name for the scaling policy"
  type        = string
}

variable "target_value" {
  description = "Target value for CPU utilization scaling"
  type        = number
}

variable "scale_in_cooldown" {
  description = "Cooldown time in seconds before scale in"
  type        = number
}

variable "scale_out_cooldown" {
  description = "Cooldown time in seconds before scale out"
  type        = number
}



