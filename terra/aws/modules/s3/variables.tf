variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "region" {
  description = "AWS region where the S3 bucket will be deployed"
  type        = string
}

variable "versioning_enabled" {
  description = "Whether to enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm"
  type        = string
  default     = "AES256"
}

variable "block_public_access" {
  description = "Whether to block public access to the bucket"
  type        = bool
  default     = true
}

variable "create_ec2_role" {
  description = "Whether to create IAM role for EC2 S3 write access"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to S3 resources"
  type        = map(string)
  default     = {}
}

variable "bucket_prefixes" {
  description = "List of prefixes to create in the S3 bucket"
  type        = list(string)
  default     = []
}
