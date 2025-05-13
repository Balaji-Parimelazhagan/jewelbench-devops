output "bucket_name" {
  description = "The names of the created S3 buckets"
  value       = aws_s3_bucket.bucket.id
}

output "frontend_bucket_regional_domain_name" {
  description = "value"
  value = aws_s3_bucket.bucket.bucket_regional_domain_name
  
}

output "frontend_s3_arn" {
  description = "ARN for the Front-end S3"
  value       = aws_s3_bucket.bucket.arn
}

output "bucket_id" {
  description = "The name of the frontend bucket"
  value       = aws_s3_bucket.bucket.id
}
