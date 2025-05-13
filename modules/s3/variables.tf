variable "bucket_name" {
  description = "List of S3 bucket names"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, prod, etc.)"
  type        = string
}

variable "acl" {
  description = "Access control for the bucket"
  type        = string
}

variable "enable_versioning" {
  description = "Enable S3 versioning"
  type        = bool
}

variable "cloudfront_distribution_arn" {
  description = "CloudFront Distribution ARN"
  type        = string
}

variable "object_ownership" {
  description = "value"
  type = string   
}
