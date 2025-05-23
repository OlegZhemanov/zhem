variable "api_gateway_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "new_api"
}

variable "api_method" {
  description = "HTTP method for the API Gateway endpoint"
  type        = string
  default     = "ANY"
}

variable "environment" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "dev"
}

variable "api_throttling_burst_limit" {
  description = "The API request burst limit, the maximum rate limit over a time ranging from one to a few seconds"
  type        = number
  default     = 50
}

variable "api_throttling_rate_limit" {
  description = "The API request steady-state rate limit"
  type        = number
  default     = 10
}

variable "api_log_destination_arn" {
  description = "ARN of the CloudWatch log group for API Gateway access logs"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the Lambda function"
  type        = map(string)
  default     = {}
}

variable "lambda_function_invoke_arn" {
  description = "Name of the API Gateway stage"
  type        = string
}

variable "api_gateway_id" {
  description = "ID of the existing API Gateway"
  type        = string
}

variable "routes" {
  description = "Map of routes to be added to the API Gateway"
  type = map(object({
    method               = string
    lambda_invoke_arn    = string
    throttling_burst_limit = optional(number, 50)
    throttling_rate_limit  = optional(number, 10)
  }))
  default = {}
}