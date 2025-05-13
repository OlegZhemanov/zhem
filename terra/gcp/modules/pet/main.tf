# Provider configuration
provider "google" {
  project = var.project_id
  region  = var.region
}

# Service account for the Cloud Function
resource "google_service_account" "email_sender" {
  account_id   = "email-sender-function"
  display_name = "Email Sender Function Service Account"
}

# IAM roles for the service account
resource "google_project_iam_member" "function_invoker" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.email_sender.email}"
}

resource "google_project_iam_member" "secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.email_sender.email}"
}

# Secret Manager secrets for SMTP credentials
resource "google_secret_manager_secret" "smtp_user" {
  secret_id = "smtp-user"
  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret" "smtp_password" {
  secret_id = "smtp-password"
  replication {
    auto { 
    }
  }
}

# Cloud Storage bucket for function source code
resource "google_storage_bucket" "function_bucket" {
  name                        = "${var.project_id}-email-function"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy              = true  # Allow Terraform to destroy the bucket even if it contains objects
}

# Zip the function source code
data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../../../scripts/python"  # Use path.module for relative paths
  output_path = "/tmp/function.zip"
  excludes    = ["__pycache__", "*.pyc"]
}

# Upload the source code to Cloud Storage
resource "google_storage_bucket_object" "function_archive" {
  name   = "function-${filemd5(data.archive_file.function_zip.output_path)}.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = data.archive_file.function_zip.output_path
}

# Cloud Function
resource "google_cloudfunctions_function" "email_sender" {
  name        = "email-sender"
  description = "Serverless email sending function"
  runtime     = "python310"
  region      = var.region

  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_archive.name
  trigger_http         = true
  entry_point         = "send_email"

  service_account_email = google_service_account.email_sender.email

  environment_variables = {
    PROJECT_ID        = var.project_id
    NOTIFICATION_EMAIL = var.terraform_deployer_email
  }

  depends_on = [
    google_project_iam_member.secret_accessor
  ]
}

# IAM entry for public access to the function
resource "google_cloudfunctions_function_iam_member" "public_invoker" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.email_sender.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"  # Allow public access
}

# Add required IAM roles for deploying Cloud Functions
resource "google_project_iam_member" "terraform_function_admin" {
  project = var.project_id
  role    = "roles/cloudfunctions.admin"
  member  = "user:${var.terraform_deployer_email}"  # Your GCP user email
}

resource "google_project_iam_member" "terraform_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "user:${var.terraform_deployer_email}"  # Your GCP user email
}

# Add variable for the deployer email
variable "terraform_deployer_email" {
  description = "Email of the GCP user deploying Terraform"
  type        = string
}

