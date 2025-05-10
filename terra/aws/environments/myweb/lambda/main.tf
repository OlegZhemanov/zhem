provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "ozs-terra"
    key    = "myweb/lambda/terraform.tfstate"
    region = "ca-central-1"
  }
}

module "lambda_main_page" {
  source = "../../../modules/lambda"
  region = var.region

  function_name        = var.function_name
  environment          = var.environment
  aws_apigatewayv2_api = aws_apigatewayv2_api.api_gateway.execution_arn
  sns                  = false
  sns_topic_arn        = module.sns.sns_topic_arn
  topic_name           = var.topic_name
  env_var_key          = var.env_var_key
  bucket_name          = var.bucket_name
}

module "sns" {
  source = "../../../modules/sns"

  topic_name = var.topic_name
}

module "lambda_first_project" {
  source = "../../../modules/lambda"
  region = var.region

  function_name        = var.function_name_first_project
  environment          = var.environment
  aws_apigatewayv2_api = aws_apigatewayv2_api.api_gateway.execution_arn
  sns                  = false
  sns_topic_arn        = module.sns.sns_topic_arn
  topic_name           = var.topic_name
  env_var_key          = var.env_var_key
  bucket_name          = var.bucket_name
}

data "archive_file" "create_zip_sender_to_sns" {
  type        = "zip"
  source_file = "../../../../../scripts/py/${var.function_name_sender_to_sns}.py"
  output_path = "./${var.function_name_sender_to_sns}.zip"
}

resource "aws_s3_object" "put_zip_sender_to_sns_to_s3" {
  bucket = var.bucket_name
  key    = "${var.environment}/myweb/${var.function_name_sender_to_sns}.zip"
  source = data.archive_file.create_zip_sender_to_sns.output_path
  etag   = filemd5(data.archive_file.create_zip_sender_to_sns.output_path)
}

module "lambda_sender_to_sns" {
  source = "../../../modules/lambda"
  region = var.region

  function_name        = var.function_name_sender_to_sns
  environment          = var.environment
  aws_apigatewayv2_api = aws_apigatewayv2_api.api_gateway.execution_arn
  sns                  = true
  sns_topic_arn        = module.sns.sns_topic_arn
  topic_name           = var.topic_name
  env_var_key          = var.env_var_key
  bucket_name          = var.bucket_name
  runtime              = var.runtime_for_sender_to_sns
  handler              = var.handler_for_sender_to_sns
  depends_on           = [aws_s3_object.put_zip_sender_to_sns_to_s3]
}

resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "${var.api_gateway_name}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api_gateway_stage" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  name        = var.environment
  auto_deploy = true

  dynamic "route_settings" {
    for_each = var.routes
    content {
      route_key              = "${route_settings.value.method} /${route_settings.key}"
      throttling_burst_limit = try(route_settings.value.throttling_burst_limit, 50)
      throttling_rate_limit  = try(route_settings.value.throttling_rate_limit, 10)
    }
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

module "path_for_main_page" {
  source = "../../../modules/path_for_api_gateway"

  api_gateway_id = aws_apigatewayv2_api.api_gateway.id

  routes = {
    "main_page" = {
      method            = var.api_method
      lambda_invoke_arn = module.lambda_main_page.lambda_function_invoke_arn
    }
  }
}

module "path_for_first_project" {
  source = "../../../modules/path_for_api_gateway"

  api_gateway_id = aws_apigatewayv2_api.api_gateway.id

  routes = {
    "first_project" = {
      method            = var.api_method
      lambda_invoke_arn = module.lambda_first_project.lambda_function_invoke_arn
    }
  }
}

module "path_for_sender" {
  source = "../../../modules/path_for_api_gateway"

  api_gateway_id = aws_apigatewayv2_api.api_gateway.id

  routes = {
    "sender_to_sns" = {
      method            = var.api_method
      lambda_invoke_arn = module.lambda_sender_to_sns.lambda_function_invoke_arn
    }
  }
}
