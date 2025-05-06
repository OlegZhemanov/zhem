provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "ozs-terra"
    key    = "myweb/api_gateway/terraform.tfstate"
    region = "ca-central-1"
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

module "api_gw" {
  source = "../../../modules/api_gateway"

}
