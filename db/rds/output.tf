output "db_instance_endpoint" {
  description = "The endpoint of the RDS instance."
  value       = aws_db_instance.postgres.endpoint
}

output "db_instance_port" {
  description = "The port the RDS instance is listening on."
  value       = aws_db_instance.postgres.port
}

output "db_name" {
  description = "The name of the created database."
  value       = var.db_name
}

output "environment" {
  description = "The environment this infrastructure is deployed in."
  value       = var.environment
}

output "db_user" {
  description = "The master username of the database."
  value       = var.db_user
  sensitive   = true
}
