provider "google" {
  project = var.project_id
  region  = var.region
}
resource "google_storage_bucket" "bucket-no-age-enabled" {
  provider = google-beta
  project = var.project_id
  name          = "${var.vpc_name}-${var.location[1]}-${var.project_id}-bucket-logs"
  location      = var.location[0]
  force_destroy = true

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      days_since_noncurrent_time = 3
      send_age_if_zero = false
    }
  }
}