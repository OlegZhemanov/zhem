variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region to deploy resources to"
  type        = string
  default     = "us-central1"
}   
# variable "terraform_deployer_email" {
#     description = "Email address to receive notifications"
#   type        = string  
# }