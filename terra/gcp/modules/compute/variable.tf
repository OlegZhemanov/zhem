variable "project_id" {
  type = string
}
variable "zone" {
  type = list(string)
}

variable "subnet_public_name" {
  type = string
}

variable "subnet_private_name" {
  type = string
}

variable "subnet_full_access_name" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "os_user" {
  type = string
}