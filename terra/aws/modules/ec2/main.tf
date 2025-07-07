data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "this" {

  ami                         = var.ami != null ? var.ami : data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip_address
  tags                        = merge(var.tags, { "Name" = var.environment != null ? "${var.environment}-ec2-instance" : "ec2-instance" })

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }
}
