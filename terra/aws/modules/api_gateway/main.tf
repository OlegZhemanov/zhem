resource "aws_apigatewayv2_api" "this" {
  name          = "${var.function_name}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "this" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"

  connection_type = "INTERNET"
  description            = "Lambda integration"
  integration_method     = "POST"
  integration_uri        = var.aws_lambda_function.this.invoke_arn
  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "${var.api_method} /${var.function_name}"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.environment
  auto_deploy = true
  depends_on  = [aws_apigatewayv2_route.this]
  route_settings {
    route_key              = "${var.api_method} /${var.function_name}"
    throttling_burst_limit = var.api_throttling_burst_limit
    throttling_rate_limit  = var.api_throttling_rate_limit
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