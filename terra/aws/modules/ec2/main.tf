data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Generate private key for the key pair
resource "tls_private_key" "generated" {
  count     = var.key_name == null ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a new key pair if no key_name is provided
resource "aws_key_pair" "generated" {
  count      = var.key_name == null ? 1 : 0
  key_name   = var.region
  public_key = tls_private_key.generated[0].public_key_openssh
  
  tags = merge(var.tags, {
    Name = "${var.region}-key-pair"
    CreatedBy = "terraform"
  })
}

# Save private key to local file (optional, but useful for access)
resource "local_file" "private_key" {
  count           = var.key_name == null ? 1 : 0
  content         = tls_private_key.generated[0].private_key_pem
  filename        = "${path.root}/${var.region}-key.pem"
  file_permission = "0600"
}

# Locals block for key pair logic
locals {
  # Determine the final key name to use
  final_key_name = var.key_name != null ? var.key_name : aws_key_pair.generated[0].key_name
}

# IAM role for EC2 to access S3
resource "aws_iam_role" "ec2_s3_role" {
  count = var.enable_s3_mount ? 1 : 0
  name  = "${var.environment}-ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM policy for S3 access
resource "aws_iam_role_policy" "s3_access_policy" {
  count = var.enable_s3_mount ? 1 : 0
  name  = "${var.environment}-s3-access-policy"
  role  = aws_iam_role.ec2_s3_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

# Instance profile for the IAM role
resource "aws_iam_instance_profile" "ec2_s3_profile" {
  count = var.enable_s3_mount ? 1 : 0
  name  = "${var.environment}-ec2-s3-profile"
  role  = aws_iam_role.ec2_s3_role[0].name

  tags = var.tags
}

# User data script for S3 mount
locals {
  # Determine which IAM instance profile to use
  instance_profile = var.iam_instance_profile != null ? var.iam_instance_profile : (var.enable_s3_mount ? aws_iam_instance_profile.ec2_s3_profile[0].name : null)
  
  # Create user data script if S3 bucket name is provided
  s3_mount_script = var.s3_bucket_name != "" ? base64encode(templatefile("${path.module}/user_data.sh", {
    s3_bucket_name  = var.s3_bucket_name
    ebs_device_name = "/dev/xvdf"
  })) : null
}

resource "aws_instance" "this" {
  ami                         = var.ami != null ? var.ami : data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = local.final_key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip_address
  iam_instance_profile        = local.instance_profile
  user_data_base64            = local.s3_mount_script
  tags                        = merge(var.tags, { "Name" = var.environment != null ? "${var.environment}-ec2-instance" : "ec2-instance" })

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }
}
