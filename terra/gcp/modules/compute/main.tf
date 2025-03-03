# Create a service account for VM instances
resource "google_service_account" "vm_sa" {
  account_id   = "terra-sa"      # Unique identifier for the service account
  display_name = "Service Account for VM"
}

# Assign compute admin role to the service account
resource "google_project_iam_binding" "vm_sa_binding" {
  project = var.project_id
  role    = "roles/compute.admin"  # Grants administrative access to compute resources

  members = [
    "serviceAccount:${google_service_account.vm_sa.email}"
  ]
}

# Generate service account key for authentication
resource "google_service_account_key" "vm_sa_key" {
  service_account_id = google_service_account.vm_sa.name
}

locals {
  ssh_public_key = file("~/.ssh/gcp_ed25519_pem.pub") # Path to SSH public key for VM access
  user = var.os_user                                   # Username for SSH access
  # Define OAuth scopes for VM service account
  scopes = [
    "https://www.googleapis.com/auth/devstorage.read_only",     # Read-only access to Cloud Storage
    "https://www.googleapis.com/auth/logging.write",            # Write access to Cloud Logging
    "https://www.googleapis.com/auth/monitoring.write",         # Write access to Cloud Monitoring
    "https://www.googleapis.com/auth/service.management.readonly", # Read-only access to Service Management
    "https://www.googleapis.com/auth/servicecontrol",           # Access to Service Control
    "https://www.googleapis.com/auth/trace.append"              # Append access to Cloud Trace
  ]
}

# Get the latest Ubuntu 22.04 LTS image
data "google_compute_image" "latest_ubuntu" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

# Create web server instance
resource "google_compute_instance" "web_instance" {
  name         = "web-instance"
  machine_type = "n1-standard-1"                    # VM instance type with 1 vCPU and 3.75 GB memory
  zone         = var.zone[0]                        # Deployment zone
  allow_stopping_for_update = true                  # Allow instance to be stopped for updates
  metadata_startup_script = "${file("../../../../scripts/phyton/create_user_auto.py")}"  # Script to run on instance startup
  
  # Network tags for firewall rules
  tags = ["http-server", "https-server", "lb-health-check", "share", "allow-ssh", "allow-public-tcp-web"]

  boot_disk {
    auto_delete = false                             # Preserve disk after instance deletion
    device_name = "web_instance"

    initialize_params {
      image = data.google_compute_image.latest_ubuntu.self_link
      size  = 20                                    # Disk size in GB
      type  = "pd-balanced"                         # Balanced persistent disk type
    }

    mode = "READ_WRITE"
  }

  labels = {
    goog-ec-src = "vm_add-tf"                      # Source label for tracking
    env = var.vpc_name                             # Environment label
  }

  network_interface {
    access_config {
      network_tier = "PREMIUM"                      # Premium network tier for better performance
    }

    queue_count = 0                                 # Number of network queues
    stack_type  = "IPV4_ONLY"                      # IP version stack type
    subnetwork  = var.subnet_full_access_name      # Subnet for the instance
  }

  metadata = {
    ssh-keys = "${local.user}:${local.ssh_public_key}}"  # SSH key for instance access
  }

  service_account {
    email  = google_service_account.vm_sa.email    # Service account email
    scopes = local.scopes                          # OAuth scopes for the instance
  }
}

resource "google_compute_instance" "backend_instance" {

  name         = "backend-instance"
  machine_type = "n1-standard-1"
  zone         = var.zone[1]
  allow_stopping_for_update = true
  metadata_startup_script = "${file("../../../../scripts/phyton/create_user_auto.py")}"
  tags = ["http-server", "https-server", "lb-health-check", "share", "allow-ssh"]

  boot_disk {
    auto_delete = false
    device_name = "backend_instance"

    initialize_params {
      image = data.google_compute_image.latest_ubuntu.self_link
      size  = 20
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  labels = {
    goog-ec-src = "vm_add-tf"
    env = var.vpc_name
  }

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = var.subnet_public_name
  }

  metadata = {
    ssh-keys = "${local.user}:${local.ssh_public_key}}"
  }

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = local.scopes
  }
}

resource "google_compute_instance" "private_instance" {

  name         = "private-instance"
  machine_type = "n1-standard-1"
  zone         = var.zone[1]
  allow_stopping_for_update = true
  metadata_startup_script = "${file("../../../../scripts/phyton/create_user_auto.py")}"
  tags = ["http-server", "https-server", "lb-health-check", "no-internet", "share", "allow-ssh"]

  boot_disk {
    auto_delete = false
    device_name = "private-instance"

    initialize_params {
      image = data.google_compute_image.latest_ubuntu.self_link
      size  = 20
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  labels = {
    goog-ec-src = "vm_add-tf"
    env = var.vpc_name
  }

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = var.subnet_private_name
  }

  metadata = {
    ssh-keys = "${local.user}:${local.ssh_public_key}}" 
  }

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = local.scopes
  }
}

# Create jump host instance for secure access to private instances
resource "google_compute_instance" "jump-host" {
  name         = "jump-host"
  machine_type = "n1-standard-1"
  allow_stopping_for_update = true
  zone = var.zone[0]
  metadata_startup_script = "${file("../../../../scripts/phyton/create_user_auto.py")}"
  tags = ["http-server", "https-server", "lb-health-check", "allow-ssh-to-jump"]

  boot_disk {
    auto_delete = false
    device_name = "jump-host"

    initialize_params {
      image = data.google_compute_image.latest_ubuntu.self_link
      size  = 20
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  labels = {
    goog-ec-src = "vm_add-tf"
    env = var.vpc_name
    ssh = "jump-host"                              # Label identifying this as jump host
  }

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }
    network_ip = "10.0.1.11"                       # Static internal IP address

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = var.subnet_full_access_name
  }
  
  metadata = {
    ssh-keys = "${local.user}:${local.ssh_public_key}}"
  }

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = local.scopes
  }
}