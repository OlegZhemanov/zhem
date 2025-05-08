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

# data "terraform_remote_state" "network" {
#   backend = "s3"
#   config = {
#     bucket = "ozs-terra"
#     key    = "myweb/network/terraform.tfstate"
#     region = var.region
#   }
# }

module "lambda_main_page" {
  source = "../../../modules/lambda"
  region = var.region

  function_name        = var.function_name
  environment          = var.environment
  aws_apigatewayv2_api = module.api_gateway.aws_apigatewayv2_api_execution_arn
  sns                  = false
  sns_topic_arn        = module.sns.sns_topic_arn
  topic_name           = var.topic_name
  env_var_key          = var.env_var_key
  bucket_name          = var.bucket_name
}

module "api_gateway" {
  source = "../../../modules/api_gateway"

  lambda_function_invoke_arn = module.lambda_main_page.lambda_function_invoke_arn
  function_name              = var.function_name
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
  aws_apigatewayv2_api = module.api_gateway_first_project.aws_apigatewayv2_api_execution_arn
  sns                  = false
  sns_topic_arn        = module.sns.sns_topic_arn
  topic_name           = var.topic_name
  env_var_key          = var.env_var_key
  bucket_name          = var.bucket_name

}

module "api_gateway_first_project" {
  source = "../../../modules/api_gateway"

  lambda_function_invoke_arn = module.lambda_first_project.lambda_function_invoke_arn
  function_name              = var.function_name_first_project
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
  aws_apigatewayv2_api = module.api_gateway_sender_to_sns.aws_apigatewayv2_api_execution_arn
  sns                  = true
  sns_topic_arn        = module.sns.sns_topic_arn
  topic_name           = var.topic_name
  env_var_key          = var.env_var_key
  bucket_name          = var.bucket_name
  runtime              = var.runtime_for_sender_to_sns
  handler              = var.handler_for_sender_to_sns
  depends_on           = [aws_s3_object.put_zip_sender_to_sns_to_s3]
}

module "api_gateway_sender_to_sns" {
  source = "../../../modules/api_gateway"

  lambda_function_invoke_arn = module.lambda_sender_to_sns.lambda_function_invoke_arn
  function_name              = var.function_name_sender_to_sns
}
