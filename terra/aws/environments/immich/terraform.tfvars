environment = "immich"
region      = "ca-central-1"

#Network
vpc_cidr                = "10.10.0.0/16"
public_subnet_cidr      = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidr     = ["10.10.11.0/24", "10.10.12.0/24"]
# private_subnet_cidr_eip = []
# database_subnets_cidr   = []

#EC2
instance_type    = "c5.large"
ami_id           = "ami-017df5c960af6d0eb"  # Will use latest Amazon Linux 2
key_name         = "ca-central-1"
root_volume_size = 10
root_volume_type = "gp3"

#Security Groups
ingress_rules = [{
  protocol        = "tcp"
  from_port       = 22
  to_port         = 22
  cidr_blocks     = ["0.0.0.0/0"]
  security_groups = []
  description     = "SSH access"
  }, {
  protocol        = "tcp"
  from_port       = 80
  to_port         = 80
  cidr_blocks     = ["0.0.0.0/0"]
  security_groups = []
  description     = "HTTP access"
  }, {
  protocol        = "tcp"
  from_port       = 443
  to_port         = 443
  cidr_blocks     = ["0.0.0.0/0"]
  security_groups = []
  description     = "HTTPS access"
  }
]

#Target Group
target_group_port     = 80
target_group_protocol = "HTTP"
health_check_path     = "/"
health_check_protocol = "HTTP"
health_check_matcher  = "200"

#Application Load Balancer
alb_internal                   = false
alb_enable_deletion_protection = false
alb_listener_port              = 80
alb_listener_protocol          = "HTTP"
alb_ssl_policy                 = "ELBSecurityPolicy-TLS-1-2-2017-01"

#Route 53
domain_name        = "zhemanov.link"
subdomain          = "photo"
create_hosted_zone = false
