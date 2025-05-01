variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}
#Network
variable "vpc_cidr" {
  description = "vpc_cidr"
  type        = string
  default = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  description = "public_subnet_cidr"
  type        = list(string)
  default = [
    "10.10.1.0/24"
  ]
}

variable "private_subnet_cidr" {
  description = "private_subnet_cidr"
  type        = list(string)
  default = [
    "10.10.11.0/24"
  ]
}

variable "private_subnet_cidr_eip" {
  description = "private_subnet_cidr_eip"
  type        = list(string)
  default = []
}

variable "database_subnets_cidr" {
  description = "database_subnets_cidr"
  type        = list(string)
  default = []
}

variable "common_tags" {
  description = "common_tags"
  type = map
  default = {
    Project = "MyWeb"
    Owner = "Oleg Zhemanov"
  }
}