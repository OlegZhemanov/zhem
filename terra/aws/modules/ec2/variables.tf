variable "environment" {
  description = "Name of the environment"
  type        = string
  default     = "default"
  
}

variable "region" {
  description = "AWS region where resources are deployed"
  type        = string
}

variable "ami" {
  description = "AMI ID for the EC2 instance (if null, will use latest Ubuntu 22.04 LTS)"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance in"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
  default     = []
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the instance"
  type        = map(string)
  default     = {}
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 8
}

variable "root_volume_type" {
  description = "Root volume type (e.g., gp2, gp3)"
  type        = string
  default     = "gp2"
}

variable "enable_s3_mount" {
  description = "Whether to enable S3 mount point"
  type        = bool
  default     = false
}

variable "s3_bucket_name" {
  description = "S3 bucket name to mount (required if enable_s3_mount is true)"
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "IAM instance profile name to attach to EC2 instance"
  type        = string
  default     = null
}

variable "s3_mount_prefix" {
  description = "List of S3 prefixes for mounting"
  type        = list(string)
  default     = []
}

variable "s3_mount_path" {
  description = "Local path where S3 bucket will be mounted"
  type        = string
  default     = "/mnt/s3-storage"
}
