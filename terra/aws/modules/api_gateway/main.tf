resource "aws_apigatewayv2_api" "this" {
  name          = "${var.api_gateway_name}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.environment
  auto_deploy = true

  dynamic "route_settings" {
    for_each = var.routes
    content {
      route_key              = "${route_settings.value.method} /${route_settings.key}"
      throttling_burst_limit = try(route_settings.value.throttling_burst_limit, 50)
      throttling_rate_limit  = try(route_settings.value.throttling_rate_limit, 10)
    }
    # Add a lifecycle block to prevent recreation if it already exists

  }

  dynamic "access_log_settings" {
    for_each = var.api_log_destination_arn != null ? [1] : []
    content {
      destination_arn = var.api_log_destination_arn
      format = jsonencode({
        requestId        = "$context.requestId"
        ip               = "$context.identity.sourceIp"
        requestTime      = "$context.requestTime"
        httpMethod       = "$context.httpMethod"
        routeKey         = "$context.routeKey"
        status           = "$context.status"
        protocol         = "$context.protocol"
        responseLength   = "$context.responseLength"
        integrationError = "$context.integration.error"
      })
    }
  }
}