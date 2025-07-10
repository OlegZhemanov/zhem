
environment = "immich"
region      = "eu-central-1"# "eu-central-1"

#Network
vpc_cidr                = "10.10.0.0/16"
public_subnet_cidr      = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidr     = ["10.10.11.0/24", "10.10.12.0/24"]
# private_subnet_cidr_eip = []
# database_subnets_cidr   = []

#EC2
instance_type    = "c4.xlarge"  #c4.4xlarge cpu16 x86_64 ram30, c5.large cpu2 x86_64 ram4, c4.xlarge cpu4 x86_64 ram7.5
# ami_id is now automatically selected based on region:
# ca-central-1: ami-017df5c960af6d0eb
# eu-central-1: ami-0f232702240acc23a
# key_name will be auto-generated using region name if not specified
root_volume_size = 500   # Increased for media storage
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

#S3 Configuration
s3_mount_path          = "/mnt/s3-immich-storage"
s3_mount_prefix        = ["photos", "videos", "backups"]
install_s3_mountpoint  = true

# Media File Sync Configuration
enable_file_sync        = true
docker_media_directory  = "/opt/immich-storage/media"
sync_file_types        = ["jpg", "jpeg", "png", "heic", "webp", "mp4", "mov", "avi", "mkv"]
remove_local_files     = false  # Keep local files as backup