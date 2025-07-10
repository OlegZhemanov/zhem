output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = aws_instance.this.private_ip
}

output "ami_id" {
  description = "The AMI ID used for the EC2 instance"
  value       = aws_instance.this.ami
}

output "availability_zone" {
  description = "The availability zone of the EC2 instance"
  value       = aws_instance.this.availability_zone
}

output "ssh_connection_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${local.final_key_name}.pem ubuntu@${aws_instance.this.public_ip}"
}

output "key_name" {
  description = "The name of the key pair used for the instance"
  value       = local.final_key_name
}

output "key_pair_created" {
  description = "Whether a new key pair was created by this module"
  value       = var.key_name == null
}

output "private_key_file" {
  description = "Path to the private key file (only if key was generated)"
  value       = var.key_name == null ? "${path.root}/${var.region}-key.pem" : null
  sensitive   = true
}

output "s3_mount_enabled" {
  description = "Whether S3 mount is enabled"
  value       = var.s3_bucket_name != ""
}

output "s3_bucket_name" {
  description = "S3 bucket name being mounted"
  value       = var.s3_bucket_name != "" ? var.s3_bucket_name : null
}

output "iam_role_arn" {
  description = "ARN of the IAM role attached to the instance for S3 access"
  value       = var.enable_s3_mount ? aws_iam_role.ec2_s3_role[0].arn : null
}