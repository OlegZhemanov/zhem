output "certificate_arn" {
  description = "ARN of the certificate"
  value       = aws_acm_certificate.this.arn
}

output "certificate_domain_name" {
  description = "Domain name of the certificate"
  value       = aws_acm_certificate.this.domain_name
}

output "certificate_status" {
  description = "Status of the certificate"
  value       = aws_acm_certificate.this.status
}

output "validation_certificate_arn" {
  description = "ARN of the validated certificate"
  value       = var.validation_method == "DNS" ? aws_acm_certificate_validation.this[0].certificate_arn : aws_acm_certificate.this.arn
}
