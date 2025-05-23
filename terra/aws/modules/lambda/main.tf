#TODO data

data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "this" {
  # s3_bucket = "ozs-storage"
  s3_bucket = var.bucket_name
  #   s3_key    = "${environment}/myweb/index.zip"
  s3_key = "${var.environment}/myweb/${var.function_name}.zip"

  function_name = var.function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = var.handler
  runtime       = var.runtime
  memory_size   = var.memory_size
  timeout       = var.timeout
  architectures = var.architectures
  ephemeral_storage {
    size = var.ephemeral_storage_size
  }


  environment {
    variables = var.sns ? { "${var.env_var_key}" = "${var.sns_topic_arn}" } : {}
  }

  tags = var.tags
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_s3_access" {
  name = "${var.function_name}-s3-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:Describe*",
          "s3-object-lambda:Get*",
          "s3-object-lambda:List*"
        ]
        Resource = "arn:aws:s3:::ozs-storage/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_logs" {
  name = "${var.function_name}-logs-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_sns" {
  count = var.sns ? 1 : 0
  name  = "${var.function_name}-sns-policy"
  role  = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : "sns:Publish",
        Resource : "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${var.topic_name}"
      }
    ]
  })
}

resource "aws_lambda_function_event_invoke_config" "this" {
  function_name                = aws_lambda_function.this.function_name
  maximum_event_age_in_seconds = var.maximum_event_age
  maximum_retry_attempts       = var.maximum_retry_attempts
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  #TODO data
  source_arn = "${var.aws_apigatewayv2_api}/*/*/${var.function_name}"
}
