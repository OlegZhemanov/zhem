variable "domain_name" {
  description = "The domain name for the hosted zone"
  type        = string
}

variable "create_hosted_zone" {
  description = "Whether to create a new hosted zone or use an existing one"
  type        = bool
  default     = false
}

variable "records" {
  description = "Map of DNS records to create"
  type = map(object({
    name                   = string
    type                   = string
    ttl                    = optional(number, 300)
    records                = optional(list(string), [])
    is_alias               = optional(bool, false)
    alias_name             = optional(string)
    alias_zone_id          = optional(string)
    evaluate_target_health = optional(bool, false)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to the hosted zone"
  type        = map(string)
  default     = {}
}
