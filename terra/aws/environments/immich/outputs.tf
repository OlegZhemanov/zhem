output "vpc_cidr" {
  value = module.network.vpc_cidr
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_cidr" {
  value = var.public_subnet_cidr
}

output "private_subnet_cidr" {
  value = var.private_subnet_cidr
}

output "private_subnet_cidr_eip" {
  value = var.private_subnet_cidr_eip
}

output "database_subnets_cidr" {
  value = var.database_subnets_cidr
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids_eip" {
  value = module.network.private_subnet_ids_eip
}

output "database_subnets_ids" {
  value = module.network.database_subnets_ids
}

# EC2 outputs
output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "EC2 instance public IP"
  value       = module.ec2.public_ip
}

output "ec2_private_ip" {
  description = "EC2 instance private IP"
  value       = module.ec2.private_ip
}

# Target Group outputs
output "target_group_arn" {
  description = "Target group ARN"
  value       = module.target_group.target_group_arn
}

output "target_group_name" {
  description = "Target group name"
  value       = module.target_group.target_group_name
}

# ALB outputs
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.load_balancer_dns_name
}

output "alb_arn" {
  description = "ALB ARN"
  value       = module.alb.load_balancer_arn
}

output "alb_zone_id" {
  description = "ALB hosted zone ID"
  value       = module.alb.load_balancer_zone_id
}

# Route 53 outputs
output "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = module.route53.zone_id
}

output "dns_records" {
  description = "Created DNS records"
  value       = module.route53.records
}

output "photo_subdomain_url" {
  description = "URL for the photo subdomain"
  value       = "http://${var.subdomain}.${var.domain_name}"
}

# SSL Certificate outputs
output "certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = module.acm.certificate_arn
}

output "certificate_status" {
  description = "Status of the SSL certificate"
  value       = module.acm.certificate_status
}

output "https_subdomain_url" {
  description = "HTTPS URL for the photo subdomain"
  value       = "https://${var.subdomain}.${var.domain_name}"
}