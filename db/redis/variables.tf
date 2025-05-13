variable "name" {
  type        = string
  description = "Prefix name for resources"
}

variable "project_name" {
  description = "Project name"
  type        = string
}


variable "node_type" {
  type        = string
  description = "Redis node type"
}

variable "num_cache_nodes" {
  type        = number
  description = "Number of cache nodes (1 for Redis)"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs"
}

variable "environment" {
  description = "Environment name"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}