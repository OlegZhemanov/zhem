variable "api_gateway_id" {
  description = "ID of the existing API Gateway"
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
