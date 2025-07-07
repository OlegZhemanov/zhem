output "zone_id" {
  description = "The hosted zone ID"
  value       = local.zone_id
}

output "zone_name" {
  description = "The hosted zone name"
  value       = var.domain_name
}

output "name_servers" {
  description = "The name servers for the hosted zone (only available if zone is created)"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].name_servers : null
}

output "records" {
  description = "Map of created DNS records"
  value = {
    for k, v in aws_route53_record.this : k => {
      name = v.name
      type = v.type
      fqdn = v.fqdn
    }
  }
}
