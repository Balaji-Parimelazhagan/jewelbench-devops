output "queue_url" {
  value = aws_sqs_queue.fifo.id
}

output "queue_arn" {
  value = aws_sqs_queue.fifo.arn
}

output "queue_name" {
  value = aws_sqs_queue.fifo.name
}
