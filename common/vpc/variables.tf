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
  description = "List of CIDR blocks for db_subnets_cidr"
  type        = list(string)
}