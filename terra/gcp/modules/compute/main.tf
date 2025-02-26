resource "google_service_account" "vm_sa" {
  account_id   = "terra-sa"
  display_name = "Service Account for VM"
}
resource "google_project_iam_binding" "vm_sa_binding" {
  project = var.project_id
  role    = "roles/compute.admin"  # Роль для доступа к Cloud Storage

  members = [
    "serviceAccount:${google_service_account.vm_sa.email}"
  ]
}

resource "google_service_account_key" "vm_sa_key" {
  service_account_id = google_service_account.vm_sa.name
}

locals {
  ssh_public_key = file("~/.ssh/gcp_ed25519_pem.pub") # Specify the path to your public SSH key
}

data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2004-lts-arm64"
  project = "ubuntu-os-cloud"
}


resource "google_compute_instance" "fill_public_instance" {
  name         = "fill-public-instance"
  machine_type = "n1-standard-1"
  zone         = var.zone[0]

  boot_disk {
    auto_delete = true
    device_name = "instance-20250225-235558"

    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = 20
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = var.subnet_full_access_name
  }

  allow_stopping_for_update = true

  metadata = {
    ssh-keys = "fraud:${local.ssh_public_key}}" # Используем локальный публичный ключ
  }

  metadata_startup_script = "${file("../../../../scripts/phyton/create_user_auto.py")}"

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  tags = ["http-server", "https-server", "lb-health-check", "full-access"]
}

resource "google_compute_instance" "public_instance" {
  name         = "public-instance"
  machine_type = "n1-standard-1"
  zone         = var.zone[1]

  boot_disk {
    auto_delete = true
    device_name = "instance-20250225-235558"

    initialize_params {
      image = "projects/centos-cloud/global/images/centos-stream-9-v20250212"
      size  = 20
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = var.subnet_public_name
  }

  allow_stopping_for_update = true

  metadata = {
    ssh-keys = "fraud:${local.ssh_public_key}}" # Используем локальный публичный ключ
  }

  metadata_startup_script = "${file("../../../../scripts/phyton/create_user_auto.py")}"

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  tags = ["public"]
}

resource "google_compute_instance" "private_instance" {
  name         = "private-instance"
  machine_type = "n1-standard-1"
  zone         = var.zone[1]

  boot_disk {
    auto_delete = true
    device_name = "instance-20250225-235558"

    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = 20
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = var.subnet_private_name
  }

  allow_stopping_for_update = true

  metadata = {
    ssh-keys = "fraud:${local.ssh_public_key}}" # Используем локальный публичный ключ
  }

  metadata_startup_script = "${file("../../../../scripts/phyton/create_user_auto.py")}"

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  tags = ["http-server", "https-server", "lb-health-check", "no-internet"]
}

resource "google_compute_instance" "instance-20250225-235558" {
  boot_disk {
    auto_delete = true
    device_name = "instance-20250225-235558"

    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = 20
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "n1-standard-1"
  allow_stopping_for_update = true
  name         = "test-test"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = var.subnet_full_access_name
  }

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  tags = ["http-server", "https-server", "lb-health-check", "full-access"]
  zone = var.zone[0]
}
