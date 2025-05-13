resource "aws_sqs_queue" "fifo" {
  name = each.key
  for_each = toset(var.sqs_name)
  fifo_queue                = true
  content_based_deduplication = var.content_based_deduplication
  delay_seconds             = 0
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds = var.message_retention_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds
  tags                      = var.tags
}


