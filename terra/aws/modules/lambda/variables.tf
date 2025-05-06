variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "new_web_app"
}

variable "handler" {
  description = "Function entrypoint in your code"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Runtime environment for the Lambda function"
  type        = string
  default     = "nodejs22.x"
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda function can use"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Amount of time your Lambda function has to run in seconds"
  type        = number
  default     = 3
}

variable "ephemeral_storage_size" {
  description = "Size of the function's /tmp directory in MB"
  type        = number
  default     = 512
}

variable "architectures" {
  description = "Instruction set architecture for your Lambda function"
  type        = list(string)
  default     = ["x86_64"]
}

variable "maximum_event_age" {
  description = "Maximum age of a request that Lambda sends to a function for processing"
  type        = number
  default     = 21600
}

variable "maximum_retry_attempts" {
  description = "Maximum number of times to retry when the function returns an error"
  type        = number
  default     = 2
}

variable "function_url_auth_type" {
  description = "Type of authentication that your function URL uses"
  type        = string
  default     = "NONE"
}

variable "function_url_invoke_mode" {
  description = "Invoke mode for the function URL"
  type        = string
  default     = "BUFFERED"
}


variable "tags" {
  description = "Tags to apply to the Lambda function"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "dev"
}

variable "aws_apigatewayv2_api" {
  description = "Name of the API Gateway stage"
  type        = string
}
