# Lambda
variable "region" {
  description = "where you are creating the Lambda, ap-south-1."
  type        = string
}

variable "role_arn" {
  description = "role_arn for resource creation."
  type        = string
}

variable "name" {
  description = "Unique name for your Lambda Function."
  type        = string
}

variable "handler" {
  description = "Function entrypoint in your code."
  type        = string
}

variable "runtime" {
  description = "Identifier of the function's runtime."
  type        = string
}

variable "memory_size" {
  type        = number
  description = "Amount of memory in MB your Lambda Function can use at runtime. Defaults to 128."
  default     = 128
}

variable "timeout" {
  type        = number
  description = "Amount of time your Lambda Function has to run in seconds. Defaults to 3."
  default     = 3
}


# sns
variable "no_of_sns_topics" {
  description = "no_of_sns_topics to create"
  type        = number
  default     = 1
}
variable "sns_topic_name" {
  description = "sns_topic_names to create.Apeend the name with .fifo if creating FIFO queues."
  type        = string
}
# variable "delivery_policy" {
#   description = "delivery_policy"
#   type        = string
# }
variable "fifo_topic" {
  description = "whether fifo topic"
  type        = bool
}
variable "content_based_deduplication" {
  description = "content_based_deduplication"
  type        = bool
}
variable "kms_master_key_id" {
  description = "kms_master_key_id"
  type        = string
}
variable "tracing_config" {
  description = "tracing config"
  type        = string
}

# variable "topic_arn" {
#   description = "The topic arn of the subscription"
#   type        = string
# }
variable "protocol" {
  description = "Protocol"
  type        = string
}
variable "endpoint" {
  description = "Endpoint"
  type        = string
}
variable "endpoint_auto_confirms" {
  description = "Endpoint Auto Confirms"
  type        = bool
}
variable "confirmation_timeout_in_minutes" {
  description = "Confirmation Timeout in minutes"
  type        = number
}
variable "subscription_role_arn" {
  description = "subscription_role_arn"
  type        = string
}