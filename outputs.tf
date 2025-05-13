output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

####### S3 Outputs ####### 

output "bucket_id" {
  value = module.s3.bucket_id
}

output "bucket_arn" {
  value = module.s3.frontend_s3_arn
}

output "bucket_name" {
  value = module.s3.bucket_name
}

output "bucket_regional_domain_name" {
  value = module.s3.frontend_bucket_regional_domain_name
}

####### RDS Outputs ####### 

output "db_name" {
  value       = var.db_name
}

output "environment" {
  value       = var.environment
}

output "db_user" {
  value       = var.db_user
  sensitive   = true
}

output "db_instance_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "db_instance_port" {
  value = module.rds.db_instance_port
}

####### Redis Outputs ####### 

output "redis_endpoint" {
  description = "Redis endpoint address"
  value       = module.redis.redis_endpoint
}

output "redis_port" {
  description = "Redis port"
  value       = module.redis.redis_port
}

# output "repository_url" {
#   description = "The URL of the created ECR repository"
#   value       = module.ecr-backend-app.repository_url
# }

# output "repository_name" {
#   description = "The name of the ECR repository"
#   value       = module.ecr.repository_name
# }

# output "repository_arn" {
#   description = "The ARN of the ECR repository"
#   value       = module.ecr.repository_arn
# }


output "ecr_backend_app_url" {
  value = module.ecr-backend-app.repository_url
}

output "ecr_backend_app_name" {
  value = module.ecr-backend-app.repository_name
}

output "ecr_backend_app_arn" {
  value = module.ecr-backend-app.repository_arn
}

# # output "ecr_hd_model_url" {
# #   value = module.ecr-hd-model.repository_url
# # }

# # output "ecr_hd_model_name" {
# #   value = module.ecr-hd-model.repository_name
# # }

# # output "ecr_hd_model_arn" {
# #   value = module.ecr-hd-model.repository_arn
# # }

# # output "ecr_text_to_3d_url" {
# #   value = module.ecr-text-to-3d-model.repository_url
# # }

# # output "ecr_text_to_3d_name" {
# #   value = module.ecr-text-to-3d-model.repository_name
# # }

# # output "ecr_text_to_3d_arn" {
# #   value = module.ecr-text-to-3d-model.repository_arn
# # }








