variable "environment" {
  description = "Environment name"
  type        = string
  default     = "default"
}

variable "name" {
  description = "Name for the EBS volume"
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "Availability zone for the EBS volume"
  type        = string
}

variable "size" {
  description = "Size of the EBS volume in GB"
  type        = number
  default     = 100
}

variable "type" {
  description = "Type of EBS volume (gp2, gp3, io1, io2, st1, sc1)"
  type        = string
  default     = "gp3"
  
  validation {
    condition = contains(["gp2", "gp3", "io1", "io2", "st1", "sc1"], var.type)
    error_message = "Volume type must be one of: gp2, gp3, io1, io2, st1, sc1."
  }
}

variable "iops" {
  description = "IOPS for the volume (only for gp3, io1, io2)"
  type        = number
  default     = null
}

variable "throughput" {
  description = "Throughput for gp3 volumes in MB/s"
  type        = number
  default     = null
}

variable "encrypted" {
  description = "Whether to encrypt the EBS volume"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (optional)"
  type        = string
  default     = null
}

variable "snapshot_id" {
  description = "Snapshot ID to create volume from (optional)"
  type        = string
  default     = null
}

variable "attach_to_instance" {
  description = "Whether to attach the volume to an EC2 instance"
  type        = bool
  default     = true
}

variable "instance_id" {
  description = "EC2 instance ID to attach the volume to"
  type        = string
  default     = null
}

variable "device_name" {
  description = "Device name for the attachment (e.g., /dev/sdf, /dev/xvdf)"
  type        = string
  default     = "/dev/xvdf"
}

variable "tags" {
  description = "Tags to apply to the EBS volume"
  type        = map(string)
  default     = {}
}
