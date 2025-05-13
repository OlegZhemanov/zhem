variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ca-central-1"
}

variable "common_tags" {
  description = "common_tags"
  type        = map(any)
  default = {
    Project = "MyWeb"
    Owner   = "Oleg Zhemanov"
  }
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "function_name_first_project" {
  description = "Name of the Lambda function"
  type        = string
}

variable "function_name_sender_to_sns" {
  description = "Name of the Lambda function"
  type        = string
}

variable "apigateway_arn" {
  type        = string
  description = "Get execution_arn from aws_apigatewayv2_api"
  default     = "put value"
}

variable "env_var_key" {
  description = "Environment variable"
  type        = string
  default     = "SNS_TOPIC_ARN"
}

variable "topic_name" {
  description = "SNS topic name"
  type        = string
}

variable "sns" {
  type    = bool
  default = false
}
variable "bucket_name" {
  type        = string
  default     = "ozs-storage"
  description = "bucket name with zip file"
}

variable "runtime_for_sender_to_sns" {
  type        = string
  description = "runtime"
  default     = "Node.js 22.x"
}

variable "handler_for_sender_to_sns" {
  type        = string
  description = "handler"
  default     = "index.handler"
}

variable "api_method" {
  description = "HTTP method for the API Gateway endpoint"
  type        = string
  default     = "ANY"
}

variable "api_gateway_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "routes" {
  description = "Map of routes to be added to the API Gateway"
  type = map(object({
    method                 = string
    lambda_invoke_arn      = string
    throttling_burst_limit = optional(number, 50)
    throttling_rate_limit  = optional(number, 10)
  }))
  default = {}
}

variable "api_log_destination_arn" {
  description = "ARN of the CloudWatch log group for API Gateway access logs"
  type        = string
  default     = null
}

variable "domain_name" {
  type = string
  description = "domain name"
}

variable "origin_id" {
  type = string
  description = "name origin"
}

