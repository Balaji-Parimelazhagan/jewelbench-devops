variable "name" {
  type        = string
  description = "Base name used for ECS resources like cluster, service, task definition, etc."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where ECS and related resources will be deployed."
}

variable "public_subnet_ids" { 
  type        = list(string)
  description = "List of public subnet IDs for load balancer or internet-facing services."
}

variable "private_subnet_ids" { 
  type        = list(string)
  description = "List of private subnet IDs for ECS tasks and EC2 instances."
}

variable "image" {
  type        = string
  description = "Docker image URI for the ECS container."
}

variable "container_port" { 
  type        = number
  description = "Port number on which the container listens."
}

variable "key_name" {
  type        = string
  description = "Name of the EC2 key pair for SSH access to ECS instances."
}

variable "sqs_name" {
  type        = string
  description = "Name of the SQS queue to be used for scaling ECS tasks."
}

variable "region" {
  type        = string
  description = "AWS region where all resources will be deployed."
}

variable "cpu" {
  type        = number
  description = "Number of CPU units used by the ECS task definition."
}

variable "memory" {
  type        = number
  description = "Amount of memory (in MiB) used by the ECS task definition."
}

variable "max_capacity" {
  type        = number
  description = "Maximum number of EC2 instances and ECS tasks to scale out to."
}

variable "min_capacity" {
  type        = number
  description = "Minimum number of EC2 instances and ECS tasks to keep running."
}


variable "instance_type"{
   type= string
}
