variable "project_id" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "subnet_cidr" {
  type = list(string)
}

variable "region" {
  type = string
}

variable "zone" {
  type = list(string)
}

variable "os_user" {
  type = string
}

variable "location" {
  type = list(string)
}