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

  private_ip_google_access = true  # Разрешить доступ к Google API из этой подсети
}

resource "google_compute_subnetwork" "subnet_private" {
  name          = "subnet-private"
  ip_cidr_range = var.subnet_cidr[2]
  region        = var.region
  network       = google_compute_network.vpc.id

  private_ip_google_access = true  # Разрешить доступ к Google API из этой подсети
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

resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
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
  target_tags   = ["public"]
}

resource "google_compute_firewall" "deny_internet" {
  name    = "deny-internet"
  network = google_compute_network.vpc.name

  direction = "EGRESS"  # Блокировка исходящего трафика

  deny {
    protocol = "all"  # Блокировать все протоколы
  }

  destination_ranges = ["0.0.0.0/0"] 
  target_tags   = ["no-internet"]
}

# Фаервол для разрешения всего трафика для подсети subnet-full-access
resource "google_compute_firewall" "allow_full_access" {
  name    = "allow-full-access"
  network = google_compute_network.vpc.name

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["full-access"]
}

