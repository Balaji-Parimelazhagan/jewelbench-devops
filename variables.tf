variable "region" {
  description = "region name"
  type = string 
}

variable "AWS_TAGS" {
  description = "Default AWS tags"
  type        = map(string)
  default     = {}
}

################################# Create VPC #############################################
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnets_cidr" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}
variable "create_eip" {
  description = "Flag to create an Elastic IP (true = create, false = skip)"
  type        = bool
}
variable "db_subnets_cidr" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}



variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}


variable "acl" {
  description = "Access control for the bucket"
  type        = string
  
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
}
variable "object_ownership" {
  description = "value"
  type = string   
}

variable "frontend_bucket_name" {
    description = "value"
    type = string  
}

variable "frontend_bucket_regional_domain_name" {
    description = "value"
    type = string
}


variable "allowed_cidrs" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "CIDR blocks allowed to access the RDS instance"
}

variable "db_name" {
  description = "The name of the database to be created."
}

variable "db_user" {
  description = "The master username for the database."
}

variable "db_password" {
  description = "The password for the master database user."
  sensitive   = true
}

variable "db_storage_type" {
  description = "The type of storage to use for the database (e.g., 'gp2', 'io1')."
}

variable "db_engine" {
  description = "The database engine to use (e.g., 'mysql', 'postgres', 'aurora')."
}

variable "engine_version" {
  description = "The version of the database engine to use."
}

variable "instance_class" {
  description = "The instance type to use for the database (e.g., 'db.t3.micro')."
}


variable "redis_name" {
  description = "Prefix name for Redis resources"
  type        = string
}

variable "redis_node_type" {
  description = "Redis instance type (e.g., cache.t3.medium)"
  type        = string
}

variable "redis_num_nodes" {
  description = "Number of Redis nodes"
  type        = number
}

# variable "repository_name" {
#   description = "Name of the ECR repository"
#   type        = string
# }

# variable "image_tag_mutability" {
#   description = "Whether image tags are MUTABLE or IMMUTABLE"
#   type        = string
#   default     = "MUTABLE"
# }

# variable "scan_on_push" {
#   description = "Enable image scan on push"
#   type        = bool
#   default     = true
# }

# variable "force_delete" {
#   description = "Force delete the ECR repo even if it contains images"
#   type        = bool
#   default     = false
# }


# variable "cluster_name" {
#   description = "The name of the ECS cluster"
#   type        = string

# }

# variable "iam_role_prefix" {
#   description = "Prefix for ECS Node IAM role"
#   type        = string

# }

# variable "iam_profile_prefix" {
#   description = "Prefix for ECS Node IAM instance profile"
#   type        = string
# }

# variable "sg_prefix" {
#   description = "Prefix for ECS node security group"
#   type        = string
# }

# variable "launch_template_prefix" {
#   description = "Prefix for ECS EC2 launch template"
#   type        = string
# }

# variable "instance_type" {
#   description = "EC2 instance type for ECS node"
#   type        = string
# }

# variable "asg_prefix" {
#   description = "Prefix for Auto Scaling Group"
#   type        = string
# }

# variable "asg_min_size" {
#   description = "Minimum size for Auto Scaling Group"
#   type        = number
# }

# variable "asg_max_size" {
#   description = "Maximum size for Auto Scaling Group"
#   type        = number
# }

# variable "capacity_provider_name" {
#   description = "Name of the ECS Capacity Provider"
#   type        = string
# }

# variable "max_scaling_step_size" {
#   description = "Maximum scaling step size for ECS Capacity Provider"
#   type        = number
# }

# variable "min_scaling_step_size" {
#   description = "Minimum scaling step size for ECS Capacity Provider"
#   type        = number
# }

# variable "target_capacity" {
#   description = "Target capacity for ECS Capacity Provider"
#   type        = number
# }

# variable "capacity_provider_base" {
#   description = "Base value for ECS Capacity Provider Strategy"
#   type        = number
# }

# variable "ecs_task_role_name_prefix" {
#   description = "Prefix for ECS task role"
#   type        = string
# }

# variable "ecs_exec_role_name_prefix" {
#   description = "Prefix for ECS execution role"
#   type        = string
# }

# variable "ecs_log_group" {
#   description = "Prefix for ECS execution role"
#   type        = string
# }

# variable "task_family" {
#   type    = string
# }


# variable "network_mode" {
#   type    = string
# }

# variable "task_cpu" {
#   type    = number
# }

# variable "task_memory" {
#   type    = number
# }

# variable "compatibilities" {
#   type    = list(string)
# }

# variable "container_name" {
#   type    = string
# }

# variable "container_port" {
#   type    = number
# }

# variable "host_port" {
#   type    = number

# }

# variable "container_environment" {
#   type = list(object({
#     name  = string
#     value = string
#   }))
# }


# # Security Groups
# variable "ecs_task_security_group" {
#   description = "Prefix for ECS Task Security Group"
#   type        = string
# }


# # variable "public_subnet_ids" {
# #   description = "List of public subnet IDs for ALB"
# #   type        = list(string)
# # }

# variable "alb_security_name" {
#   description = "Prefix for ALB Security Group"
#   type        = string
# }

# # ALB
# variable "loadbalancer_name" {
#   description = "Name of the ALB"
#   type        = string
# }

# variable "alb_target_group_name" {
#   description = "Prefix for the target group name"
#   type        = string
# }

# # ECS Service
# variable "ecs_service_name" {
#   description = "Name of the ECS service"
#   type        = string
# }

# # Auto Scaling
# variable "ecs_autoscaling_target" {
#   description = "ECS service namespace (should be 'ecs')"
#   type        = string
#   default     = "ecs"
# }

# variable "ecs_service_min_capacity" {
#   description = "Minimum ECS service task count"
#   type        = number
# }

# variable "ecs_service_max_capacity" {
#   description = "Maximum ECS service task count"
#   type        = number
# }

# variable "scaling_policy_name" {
#   description = "Name for the scaling policy"
#   type        = string
# }

# variable "target_value" {
#   description = "Target value for CPU utilization scaling"
#   type        = number
# }

# variable "scale_in_cooldown" {
#   description = "Cooldown time in seconds before scale in"
#   type        = number
# }

# variable "scale_out_cooldown" {
#   description = "Cooldown time in seconds before scale out"
#   type        = number
# }


# variable "sqs_name" {
#   description = "The name of the SQS FIFO queue (without .fifo suffix)"
#   type        = string
# }

# variable "content_based_deduplication" {
#   description = "Enable content-based deduplication"
#   type        = bool
#   # default     = true
# }

# variable "delay_seconds" {
#   description = "Delay in seconds for message delivery"
#   type        = number
#   # default     = 0
# }

# variable "visibility_timeout_seconds" {
#   description = "The visibility timeout for the queue"
#   type        = number
#   # default     = 30
# }

# variable "message_retention_seconds" {
#   description = "How long messages are retained"
#   type        = number
#   # default     = 345600  # 4 days
# }

# variable "receive_wait_time_seconds" {
#   description = "How long a ReceiveMessage call waits"
#   type        = number
#   # default     = 0
# }








