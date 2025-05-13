
output "s3_bucket_name" {
  value = aws_s3_bucket.input.bucket
  description = "Name of the input S3 bucket"
}

output "sqs_queue_url" {
  value = aws_sqs_queue.this.url
  description = "URL of the SQS queue"
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
  description = "Name of the ECS cluster"
}
