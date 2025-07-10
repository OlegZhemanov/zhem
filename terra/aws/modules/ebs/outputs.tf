output "volume_id" {
  description = "ID of the EBS volume"
  value       = aws_ebs_volume.this.id
}

output "volume_arn" {
  description = "ARN of the EBS volume"
  value       = aws_ebs_volume.this.arn
}

output "volume_size" {
  description = "Size of the EBS volume"
  value       = aws_ebs_volume.this.size
}

output "volume_type" {
  description = "Type of the EBS volume"
  value       = aws_ebs_volume.this.type
}

output "volume_iops" {
  description = "IOPS of the EBS volume"
  value       = aws_ebs_volume.this.iops
}

output "volume_throughput" {
  description = "Throughput of the EBS volume"
  value       = aws_ebs_volume.this.throughput
}

output "volume_encrypted" {
  description = "Whether the EBS volume is encrypted"
  value       = aws_ebs_volume.this.encrypted
}

output "volume_kms_key_id" {
  description = "KMS key ID used for encryption"
  value       = aws_ebs_volume.this.kms_key_id
}

output "availability_zone" {
  description = "Availability zone of the EBS volume"
  value       = aws_ebs_volume.this.availability_zone
}

output "attachment_id" {
  description = "ID of the volume attachment"
  value       = var.attach_to_instance ? aws_volume_attachment.this[0].id : null
}

output "attachment_device_name" {
  description = "Device name of the volume attachment"
  value       = var.attach_to_instance ? aws_volume_attachment.this[0].device_name : null
}

output "attachment_instance_id" {
  description = "Instance ID of the volume attachment"
  value       = var.attach_to_instance ? aws_volume_attachment.this[0].instance_id : null
}
