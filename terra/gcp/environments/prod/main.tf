provider "google" {
  project = var.project_id # Replace with your GCP project ID
  region  = var.region     # Replace with your desired region
}

module "network" {
    source = "../../modules/network"

    vpc_name    = var.vpc_name
    vpc_cidr    = var.vpc_cidr
    subnet_cidr = var.subnet_cidr[*]
    region      = var.region 
}