resource "aws_apigatewayv2_integration" "this" {
  for_each = var.routes

  api_id                 = var.api_gateway_id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  description            = "Lambda integration for ${each.key}"
  integration_method     = "POST"
  integration_uri        = each.value.lambda_invoke_arn
  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "this" {
  for_each = var.routes

  api_id    = var.api_gateway_id
  route_key = "${each.value.method} /${each.key}"
  target    = "integrations/${aws_apigatewayv2_integration.this[each.key].id}"
}
