provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "ozs-terra"
    key = "myweb/network/terraform.tfstate"
    region = "ca-central-1"
  }
}

module "network" {
  source = "../../modules/network"

  env                     = var.environment
  vpc_cidr                = var.vpc_cidr
  public_subnet_cidr      = var.public_subnet_cidr
  private_subnet_cidr     = var.private_subnet_cidr
  private_subnet_cidr_eip = var.private_subnet_cidr_eip
  database_subnets_cidr   = var.database_subnets_cidr
  common_tags = var.common_tags
}


