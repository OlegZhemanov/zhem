provider "google" {
  project = var.project_id # Replace with your GCP project ID
  region  = var.region     # Replace with your desired region
}

module "pet" {
  source = "../../modules/pet"
  project_id = var.project_id
  region = var.region
  terraform_deployer_email = var.terraform_deployer_email
}