resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets

  enable_deletion_protection = var.enable_deletion_protection

  tags = var.tags
}

resource "aws_lb_listener" "this" {
  count             = length(var.listeners)
  load_balancer_arn = aws_lb.this.arn
  port              = var.listeners[count.index].port
  protocol          = var.listeners[count.index].protocol
  ssl_policy        = var.listeners[count.index].protocol == "HTTPS" ? var.listeners[count.index].ssl_policy : null
  certificate_arn   = var.listeners[count.index].protocol == "HTTPS" ? var.listeners[count.index].certificate_arn : null

  default_action {
    type             = var.listeners[count.index].default_action_type
    target_group_arn = var.listeners[count.index].default_action_type == "forward" ? var.listeners[count.index].target_group_arn : null

    dynamic "redirect" {
      for_each = var.listeners[count.index].default_action_type == "redirect" ? [1] : []
      content {
        port        = var.listeners[count.index].redirect_port
        protocol    = var.listeners[count.index].redirect_protocol
        status_code = var.listeners[count.index].redirect_status_code
      }
    }

    dynamic "fixed_response" {
      for_each = var.listeners[count.index].default_action_type == "fixed-response" ? [1] : []
      content {
        content_type = var.listeners[count.index].fixed_response_content_type
        message_body = var.listeners[count.index].fixed_response_message_body
        status_code  = var.listeners[count.index].fixed_response_status_code
      }
    }
  }
}
