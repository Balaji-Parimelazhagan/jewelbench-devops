variable "name" {
  description = "The name of the SQS FIFO queue (without .fifo suffix)"
  type        = string
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication"
  type        = bool
#   default     = true
}

variable "delay_seconds" {
  description = "Delay in seconds for message delivery"
  type        = number
#   default     = 0
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue"
  type        = number
#   default     = 30
}

variable "message_retention_seconds" {
  description = "How long messages are retained"
  type        = number
#   default     = 345600  # 4 days
}

variable "receive_wait_time_seconds" {
  description = "How long a ReceiveMessage call waits"
  type        = number
#   default     = 0
}

variable "tags" {
  description = "Tags to apply to the queue"
  type        = map(string)
  default     = {}
}



