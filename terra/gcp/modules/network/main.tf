resource "google_compute_network" "vpc" {
  name                    = "${var.vpc_name}-vpc"  # Name of the VPC network with vpc_name variable prefix
  auto_create_subnetworks = false                 # Disable automatic subnet creation
  routing_mode            = "REGIONAL"            # Set routing scope to regional instead of global
}

resource "google_compute_subnetwork" "subnet_full_access" {
  name          = "subnet-full-access"           # Name of the full access subnet
  ip_cidr_range = var.subnet_cidr[0]            # CIDR range for the subnet from variable array
  region        = var.region                     # GCP region where subnet will be created
  network       = google_compute_network.vpc.id  # Reference to parent VPC network
  private_ip_google_access = false               # Disable private Google API access
}

resource "google_compute_subnetwork" "subnet_public" {
  name          = "subnet-public"               # Name of the public subnet
  ip_cidr_range = var.subnet_cidr[1]           # CIDR range for the subnet from variable array
  region        = var.region                    # GCP region where subnet will be created
  network       = google_compute_network.vpc.id # Reference to parent VPC network
  private_ip_google_access = true              # Enable private Google API access
}

resource "google_compute_subnetwork" "subnet_private" {
  name          = "subnet-private"              # Name of the private subnet
  ip_cidr_range = var.subnet_cidr[2]           # CIDR range for the subnet from variable array
  region        = var.region                    # GCP region where subnet will be created
  network       = google_compute_network.vpc.id # Reference to parent VPC network
  private_ip_google_access = true              # Enable private Google API access
}

resource "google_compute_router" "router" {
  name    = "${var.vpc_name}-router"           # Name of the Cloud Router with vpc_name prefix
  network = google_compute_network.vpc.id      # VPC network for the router
  region  = var.region                         # GCP region for the router
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.vpc_name}-nat"          # Name of the NAT gateway
  router                             = google_compute_router.router.name # Associated router name
  region                             = var.region                     # GCP region for NAT
  nat_ip_allocate_option             = "AUTO_ONLY"                   # Automatically allocate NAT IPs
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"        # NAT only specific subnets

  subnetwork {
    name                    = google_compute_subnetwork.subnet_public.id # Public subnet for NAT
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]                       # NAT all IPs in subnet
  }
}
# Share network
resource "google_compute_firewall" "share" {
  name    = "share"                            # Name of the internal sharing firewall rule
  network = google_compute_network.vpc.name    # VPC network for the rule

  allow {
    protocol = "icmp"                          # Allow ICMP traffic
  }

  allow {
    protocol = "tcp"                           # Allow all TCP ports
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"                           # Allow all UDP ports
    ports    = ["0-65535"]
  }

  source_ranges = [var.subnet_cidr[0], var.subnet_cidr[1], var.subnet_cidr[2]]  # Allow traffic from all subnets
  target_tags   = ["share"]                    # Apply to instances with 'share' tag
}

resource "google_compute_firewall" "deny_internet" {
  name    = "deny-internet"                    # Name of the internet blocking rule
  network = google_compute_network.vpc.name    # VPC network for the rule

  direction = "EGRESS"                         # Apply to outgoing traffic

  deny {
    protocol = "all"                           # Block all protocols
  }

  destination_ranges = ["0.0.0.0/0"]           # Block access to all external IPs
  target_tags   = ["no-internet"]              # Apply to instances with 'no-internet' tag
}

# Allow connection to the jump host
resource "google_compute_firewall" "allow-ssh-to-jump" {
  name    = "allow-ssh-to-jump"               # Name of the jump host SSH access rule
  network = google_compute_network.vpc.name    # VPC network for the rule

  direction = "INGRESS"                       # Apply to incoming traffic
  
  allow {
    protocol = "tcp"                          # Allow TCP protocol
    ports    = ["22"]                        # Allow SSH port
  }

  source_ranges = ["0.0.0.0/0"]              # Allow SSH from anywhere
  target_tags   = ["allow-ssh-to-jump"]      # Apply to instances with 'allow-ssh-to-jump' tag
}

# Allow connection only from a specific host
resource "google_compute_firewall" "allow_ssh_from_jump_host" {
  name    = "allow-ssh-from-jump-host"       # Name of the restricted SSH access rule
  network = google_compute_network.vpc.name   # VPC network for the rule

  direction = "INGRESS"                      # Apply to incoming traffic

  allow {
    protocol = "tcp"                         # Allow TCP protocol
    ports    = ["22"]                       # Allow SSH port
  }

  source_ranges = ["10.0.1.11/32"]          # Allow SSH only from jump host IP
  target_tags = ["allow-ssh"]               # Apply to instances with 'allow-ssh' tag
}

resource "google_compute_firewall" "allow_public_tcp_web" {
  name = "allow-public-tcp-web"             # Name of the web access rule
  network = google_compute_network.vpc.name  # VPC network for the rule

  allow {
    protocol = "icmp"                       # Allow ICMP traffic
  }

  allow {
    protocol = "tcp"                        # Allow web ports
    ports    = ["80", "8080", "443"]       # HTTP, alternate HTTP, and HTTPS ports
  }

  source_ranges = ["0.0.0.0/0"]            # Allow access from anywhere
  target_tags   = ["allow-public-tcp-web"] # Apply to instances with 'allow-public-tcp-web' tag
}

