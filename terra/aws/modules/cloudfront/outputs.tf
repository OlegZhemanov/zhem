output "aws_cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.api_gateway.id
}

output "aws_acm_certificate_id" {
  value = aws_acm_certificate.cloudfront_cert.domain_name
}

output "aws_acm_certificate_arn" {
  value = aws_acm_certificate.cloudfront_cert.arn
}