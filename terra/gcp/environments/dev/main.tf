provider "google" {
  project = var.project_id # Replace with your GCP project ID
  region  = var.region     # Replace with your desired region
}

# Read the public SSH key from the local computer

module "network" {
    source = "../../modules/network"

    vpc_name    = var.vpc_name
    vpc_cidr    = var.vpc_cidr
    subnet_cidr = var.subnet_cidr[*]
    region      = var.region 
}

module "compute" {
    source = "../../modules/compute"

    zone = var.zone[*]
    subnet_public_name = module.network.subnet_public_name
    subnet_private_name = module.network.subnet_private_name
    subnet_full_access_name = module.network.subnet_full_access_name
    project_id = var.project_id
    vpc_name    = var.vpc_name
    os_user = var.os_user
}

module "data" {
    source = "../../modules/data"
    location = var.location[*]
    project_id = var.project_id
    vpc_name = var.vpc_name
    region = var.region
}