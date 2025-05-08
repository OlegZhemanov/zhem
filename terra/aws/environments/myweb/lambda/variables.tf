variable "environment" {
  description = "Environment name"
  type        = string
  default = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default = "ca-central-1"
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
  default = "put value"
}

variable "env_var_key" {
  description = "Environment variable"
  type        = string
  default = "SNS_TOPIC_ARN"
}

variable "topic_name" {
  description = "SNS topic name"
  type        = string
}

variable "sns" {
  type = bool
  default = false
}
variable "bucket_name" {
  type = string
  default = "ozs-storage"
  description = "bucket name with zip file"
}

variable "runtime_for_sender_to_sns" {
  type = string
  description = "runtime"
  default = "Node.js 22.x"
}

variable "handler_for_sender_to_sns" {
  type = string
  description = "handler"
  default = "index.handler"
}



