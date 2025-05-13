variable "domain_name" {
  type = string
  description = "domain name"
}

variable "origin_id" {
  type = string
  description = "name origin"
}

variable "origin_path" {
  type = string
  description = "origin path. api geteway stage"
}

variable "aws_apigatewayv2_api_id" {
  type = string
  description = "aws_apigatewayv2_api_id"
}