output "ecs_cluster_name" {
  description = "The name of the ECS Cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS Cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_capacity_provider_name" {
  description = "The name of the ECS Capacity Provider"
  value       = aws_ecs_capacity_provider.main.name
}

output "ecs_autoscaling_group_name" {
  description = "The name of the ECS Auto Scaling Group"
  value       = aws_autoscaling_group.ecs.name
}

output "ecs_autoscaling_group_arn" {
  description = "The ARN of the ECS Auto Scaling Group"
  value       = aws_autoscaling_group.ecs.arn
}

output "ecs_launch_template_id" {
  description = "The ID of the ECS Launch Template"
  value       = aws_launch_template.ecs_ec2.id
}

output "ecs_launch_template_latest_version" {
  description = "Latest version of the Launch Template"
  value       = aws_launch_template.ecs_ec2.latest_version
}

output "ecs_instance_profile_arn" {
  description = "ARN of the IAM instance profile for ECS nodes"
  value       = aws_iam_instance_profile.ecs_node.arn
}

output "ecs_iam_role_name" {
  description = "IAM Role name for ECS instances"
  value       = aws_iam_role.ecs_node_role.name
}

output "ecs_security_group_id" {
  description = "The ID of the ECS Security Group"
  value       = aws_security_group.ecs_node_sg.id
}



output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "ecs_exec_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_exec_role.arn
}

output "ecs_task_role_name" {
  description = "Name of the ECS task role"
  value       = aws_iam_role.ecs_task_role.name
}

output "ecs_exec_role_name" {
  description = "Name of the ECS task execution role"
  value       = aws_iam_role.ecs_exec_role.name
}


output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app.name
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.app.arn
}

