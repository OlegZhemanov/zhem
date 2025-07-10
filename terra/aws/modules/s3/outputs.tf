output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_region" {
  description = "Region where the S3 bucket is deployed"
  value       = var.region
}

output "iam_role_arn" {
  description = "ARN of the IAM role for S3 write access"
  value       = var.create_ec2_role ? aws_iam_role.s3_access_role[0].arn : null
}

output "instance_profile_name" {
  description = "Name of the IAM instance profile for S3 write access"
  value       = var.create_ec2_role ? aws_iam_instance_profile.s3_access_profile[0].name : null
}
