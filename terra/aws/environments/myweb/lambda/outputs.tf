output "CloudFront_distribution_id" {
  value = module.CloudFront.aws_cloudfront_distribution_id
}

output "aws_acm_certificate_id" {
  value = module.CloudFront.aws_acm_certificate_id
}

output "aws_acm_certificate_arn" {
  value = module.CloudFront.aws_acm_certificate_arn
}

output "URL" {
  value = "https://${module.CloudFront.aws_acm_certificate_id}"
}