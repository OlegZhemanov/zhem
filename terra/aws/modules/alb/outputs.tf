output "load_balancer_id" {
  description = "The ID of the load balancer"
  value       = aws_lb.this.id
}

output "load_balancer_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.this.arn
}

output "load_balancer_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics"
  value       = aws_lb.this.arn_suffix
}

output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.this.dns_name
}

output "load_balancer_zone_id" {
  description = "The canonical hosted zone ID of the load balancer"
  value       = aws_lb.this.zone_id
}

output "listener_arns" {
  description = "The ARNs of the load balancer listeners"
  value       = aws_lb_listener.this[*].arn
}
