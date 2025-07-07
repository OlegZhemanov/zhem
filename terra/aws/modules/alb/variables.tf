variable "name" {
  description = "Name of the load balancer"
  type        = string
}

variable "internal" {
  description = "Whether the load balancer is internal or internet-facing"
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "List of security group IDs to assign to the load balancer"
  type        = list(string)
}

variable "subnets" {
  description = "List of subnet IDs to attach to the load balancer"
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection on the load balancer"
  type        = bool
  default     = false
}

variable "listeners" {
  description = "List of listener configurations"
  type = list(object({
    port                          = number
    protocol                      = string
    ssl_policy                    = optional(string, "ELBSecurityPolicy-TLS-1-2-2017-01")
    certificate_arn               = optional(string)
    default_action_type           = string
    target_group_arn              = optional(string)
    redirect_port                 = optional(string)
    redirect_protocol             = optional(string)
    redirect_status_code          = optional(string, "HTTP_301")
    fixed_response_content_type   = optional(string)
    fixed_response_message_body   = optional(string)
    fixed_response_status_code    = optional(string)
  }))
  default = [
    {
      port                = 80
      protocol            = "HTTP"
      default_action_type = "forward"
    }
  ]
}

variable "tags" {
  description = "Tags to apply to the load balancer"
  type        = map(string)
  default     = {}
}
