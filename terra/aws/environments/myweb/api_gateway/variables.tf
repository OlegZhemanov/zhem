variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "common_tags" {
  description = "common_tags"
  type = map
  default = {
    Project = "MyWeb"
    Owner = "Oleg Zhemanov"
  }
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "new_web_app"
}

variable "api_method" {
  description = "HTTP method for the API Gateway endpoint"
  type        = string
  default     = "ANY"
}