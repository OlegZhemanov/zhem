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
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  description = "public_subnet_cidr"
  type        = list(string)
  default = [
    "10.10.1.0/24",
    "10.10.2.0/24"
  ]
}

variable "private_subnet_cidr" {
  description = "private_subnet_cidr"
  type        = list(string)
  default = [
    "10.10.11.0/24",
    "10.10.12.0/24"
  ]
}

variable "private_subnet_cidr_eip" {
  description = "private_subnet_cidr_eip"
  type        = list(string)
  default     = []
}

variable "database_subnets_cidr" {
  description = "database_subnets_cidr"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "common_tags"
  type        = map(any)
  default = {
    Project = "Immich"
    Owner   = "Oleg Zhemanov"
  }
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance (if null, will use latest Ubuntu 22.04 LTS)"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Key name for the EC2 instance (if null, will create a new key pair named after the region)"
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 10
}

variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "ingress_rules" {
  description = "Ingress rules for security groups"
  type = list(object({
    protocol        = string
    from_port       = number
    to_port         = number
    cidr_blocks     = list(string)
    security_groups = optional(list(string), [])
    description     = optional(string, "")
  }))
  default = [
    {
      protocol        = "tcp"
      from_port       = 22
      to_port         = 22
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
      description     = "SSH access"
    }
  ]
}

variable "egress_rules" {
  description = "Egress rules for security groups"
  type = list(object({
    protocol        = string
    from_port       = number
    to_port         = number
    cidr_blocks     = list(string)
    security_groups = optional(list(string), [])
    description     = optional(string, "")
  }))
  default = [
    {
      protocol        = "-1"
      from_port       = 0
      to_port         = 0
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
      description     = "Allow all outbound traffic"
    }
  ]
}

# Target Group variables
variable "target_group_port" {
  description = "Port on which targets receive traffic"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocol to use for routing traffic to the targets"
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "Destination for the health check request"
  type        = string
  default     = "/"
}

variable "health_check_port" {
  description = "Port to use to connect with the target"
  type        = string
  default     = "traffic-port"
}

variable "health_check_protocol" {
  description = "Protocol to use to connect with the target"
  type        = string
  default     = "HTTP"
}

variable "health_check_matcher" {
  description = "Response codes to use when checking for a healthy responses"
  type        = string
  default     = "200"
}

# Application Load Balancer variables
variable "alb_internal" {
  description = "Whether the ALB is internal or internet-facing"
  type        = bool
  default     = false
}

variable "alb_enable_deletion_protection" {
  description = "Whether to enable deletion protection on the ALB"
  type        = bool
  default     = false
}

variable "alb_listener_port" {
  description = "Port for the ALB listener"
  type        = number
  default     = 80
}

variable "alb_listener_protocol" {
  description = "Protocol for the ALB listener"
  type        = string
  default     = "HTTP"
}

variable "alb_ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "alb_certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener"
  type        = string
  default     = null
}

# Route 53 variables
variable "domain_name" {
  description = "The domain name for DNS records"
  type        = string
  default     = "zhemanov.link"
}

variable "subdomain" {
  description = "The subdomain name"
  type        = string
  default     = "photo"
}

variable "create_hosted_zone" {
  description = "Whether to create a new hosted zone or use existing"
  type        = bool
  default     = false
}

# S3 Configuration
variable "s3_bucket_name" {
  description = "S3 bucket name for media file sync (overrides default naming)"
  type        = string
  default     = null
}

variable "s3_mount_path" {
  description = "Local path where S3 bucket will be mounted"
  type        = string
  default     = "/mnt/immich-storage"
}

variable "s3_bucket_prefixes" {
  description = "List of prefixes to create in the S3 bucket for organizing content"
  type        = list(string)
  default = [
    "photos/",
    "videos/"
  ]
}

variable "s3_mount_prefix" {
  description = "List of S3 prefixes for mounting (used in terraform.tfvars)"
  type        = list(string)
  default     = ["photos", "videos", "backups"]
}

variable "install_s3_mountpoint" {
  description = "Whether to install and configure S3 Mountpoint"
  type        = bool
  default     = true
}

# Media File Sync Configuration
variable "enable_file_sync" {
  description = "Whether to enable automatic file sync to S3"
  type        = bool
  default     = true
}

variable "docker_media_directory" {
  description = "Directory path where Docker containers will save media files"
  type        = string
  default     = "/opt/immich-storage/media"
}

variable "sync_file_types" {
  description = "List of file extensions to sync (without dots)"
  type        = list(string)
  default     = ["jpg", "jpeg", "png", "heic", "webp", "mp4", "mov", "avi", "mkv"]
}

variable "remove_local_files" {
  description = "Whether to remove local files after successful S3 upload"
  type        = bool
  default     = false
}
