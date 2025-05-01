variable "env" {
  description = "Environment name"
  type        = string
  default = "dev"
}

variable "vpc_cidr" {
  description = "cidr_block_vpc"
}

variable "public_subnet_cidr" {
  description = "public_subnet_cidr"
}

variable "private_subnet_cidr" {
  description = "public_subnet_cidr"
}

variable "private_subnet_cidr_eip" {
  description = "public_subnet_cidr"
  default = []
}

variable "database_subnets_cidr" {
  description = "database_subnets_cidr"
  default = []
}

variable "common_tags" {
  description = "common_tags"
}
