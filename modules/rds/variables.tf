variable "environment" {
  description = "Environment name"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "allowed_cidrs" {
  description = "CIDR blocks allowed to access the RDS instance"
  type        = list(string)
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
