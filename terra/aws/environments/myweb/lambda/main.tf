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

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "ozs-terra"
    key    = "myweb/network/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "lambda" {
  backend = "s3"
  config = {
    bucket = "ozs-terra"
    key    = "myweb/lambda/terraform.tfstate"
    region = var.region
  }
  
}

module "lambda_main_page" {
  source = "../../../modules/lambda"

  function_name = var.function_name
  environment = var.environment
  aws_apigatewayv2_api = module.api_gateway.aws_apigatewayv2_api_execution_arn
}


module "api_gateway" {
  source = "../../../modules/api_gateway"

  function_name = var.function_name
}
