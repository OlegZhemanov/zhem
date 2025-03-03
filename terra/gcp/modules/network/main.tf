resource "google_compute_network" "vpc" {
  name                    = "${var.vpc_name}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "subnet_full_access" {
  name          = "subnet-full-access"
  ip_cidr_range = var.subnet_cidr[0]
  region        = var.region
  network       = google_compute_network.vpc.id
  private_ip_google_access = false
}

resource "google_compute_subnetwork" "subnet_public" {
  name          = "subnet-public"
  ip_cidr_range = var.subnet_cidr[1]
  region        = var.region
  network       = google_compute_network.vpc.id

  private_ip_google_access = true  # Allow access to the Google API from this subnet
}

resource "google_compute_subnetwork" "subnet_private" {
  name          = "subnet-private"
  ip_cidr_range = var.subnet_cidr[2]
  region        = var.region
  network       = google_compute_network.vpc.id

  private_ip_google_access = true  # Allow access to the Google API from this subnet
}

resource "google_compute_router" "router" {
  name    = "${var.vpc_name}-router"
  network = google_compute_network.vpc.id
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.vpc_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.subnet_public.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
# Share network
resource "google_compute_firewall" "share" {
  name    = "share"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [var.subnet_cidr[0], var.subnet_cidr[1], var.subnet_cidr[2]]
  target_tags   = ["share"]
}

resource "google_compute_firewall" "deny_internet" {
  name    = "deny-internet"
  network = google_compute_network.vpc.name

  direction = "EGRESS"  # Blocking outgoing traffic

  deny {
    protocol = "all"  # Block all protocols
  }

  destination_ranges = ["0.0.0.0/0"] 
  target_tags   = ["no-internet"]
}

# Allow connection to the jump host
resource "google_compute_firewall" "allow-ssh-to-jump" {
  name    = "allow-ssh-to-jump"
  network = google_compute_network.vpc.name

  direction = "INGRESS"
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] 
  target_tags   = ["allow-ssh-to-jump"]
}

# Allow connection only from a specific host
resource "google_compute_firewall" "allow_ssh_from_jump_host" {
  name    = "allow-ssh-from-jump-host"
  network = google_compute_network.vpc.name

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["10.0.1.11/32"]  # Allow access only from this IP address

  target_tags = ["allow-ssh"]  # Apply the rule only to VMs with this tag
}

resource "google_compute_firewall" "allow_public_tcp_web" {
  name = "allow-public-tcp-web"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-public-tcp-web"]
}

