provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "ozs-terra"
    key = "immich/network/terraform.tfstate"
    region = "ca-central-1"
  }
}

module "network" {
  source = "../../modules/network"

  env                     = var.environment
  vpc_cidr                = var.vpc_cidr
  public_subnet_cidr      = var.public_subnet_cidr
  private_subnet_cidr     = var.private_subnet_cidr
  private_subnet_cidr_eip = var.private_subnet_cidr_eip
  database_subnets_cidr   = var.database_subnets_cidr
  common_tags = var.common_tags
}

module "ec2" {
  source = "../../modules/ec2"

  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  subnet_id               = module.network.public_subnet_ids[0]
  security_group_ids      = [module.ec2_security_group.security_group_id]
  associate_public_ip_address = true
  tags                    = var.common_tags
  environment             = var.environment

  root_volume_size        = var.root_volume_size
  root_volume_type        = var.root_volume_type
}

module "ec2_security_group" {
  source = "../../modules/security_group"

  name        = "${var.environment}-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = module.network.vpc_id
  
  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules
  
  tags = var.common_tags
}

module "alb_security_group" {
  source = "../../modules/security_group"

  name        = "${var.environment}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = module.network.vpc_id
  
  ingress_rules = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
      description     = "HTTP from internet"
    },
    {
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
      description     = "HTTPS from internet"
    }
  ]
  
  tags = var.common_tags
}

module "target_group" {
  source = "../../modules/target_group"

  name                     = "${var.environment}-tg"
  port                     = var.target_group_port
  protocol                 = var.target_group_protocol
  vpc_id                   = module.network.vpc_id
  target_ids               = [module.ec2.instance_id]
  
  health_check_path        = var.health_check_path
  health_check_port        = var.health_check_port
  health_check_protocol    = var.health_check_protocol
  health_check_matcher     = var.health_check_matcher
  
  tags                     = var.common_tags
}

module "alb" {
  source = "../../modules/alb"

  name            = "${var.environment}-alb"
  internal        = var.alb_internal
  security_groups = [module.alb_security_group.security_group_id]
  subnets         = module.network.public_subnet_ids
  
  enable_deletion_protection = var.alb_enable_deletion_protection
  
  listeners = [
    {
      port                = 80
      protocol            = "HTTP"
      default_action_type = "redirect"
      redirect_port       = "443"
      redirect_protocol   = "HTTPS"
      redirect_status_code = "HTTP_301"
    },
    {
      port                = 443
      protocol            = "HTTPS"
      ssl_policy          = var.alb_ssl_policy
      certificate_arn     = module.acm.validation_certificate_arn
      default_action_type = "forward"
      target_group_arn    = module.target_group.target_group_arn
    }
  ]
  
  tags = var.common_tags
}

module "acm" {
  source = "../../modules/acm"

  domain_name               = "${var.subdomain}.${var.domain_name}"
  subject_alternative_names = []
  validation_method         = "DNS"
  route53_zone_id          = module.route53.zone_id

  tags = var.common_tags
}

module "route53" {
  source = "../../modules/route53"

  domain_name        = var.domain_name
  create_hosted_zone = var.create_hosted_zone

  records = {
    photo = {
      name                   = var.subdomain
      type                   = "A"
      is_alias               = true
      alias_name             = module.alb.load_balancer_dns_name
      alias_zone_id          = module.alb.load_balancer_zone_id
      evaluate_target_health = true
    }
  }

  tags = var.common_tags
}