# Immich Environment - AWS Infrastructure

This Terraform configuration deploys a complete AWS infrastructure for running Immich (self-hosted photo and video management) with S3 integration for media storage.

## Architecture Overview

The infrastructure includes:
- **VPC** with public/private subnets across multiple AZs
- **EC2 instance** (t3.medium) with S3 mounting capabilities
- **Application Load Balancer** with SSL termination
- **S3 bucket** for media file storage with automatic sync
- **Route 53** DNS configuration
- **ACM SSL certificate** for HTTPS
- **Security groups** for secure network access

## Features

- **S3 Mount Integration**: Automatic mounting of S3 bucket using AWS S3 Mountpoint
- **File Sync Service**: Automated sync of media files from Docker containers to S3
- **SSL/HTTPS**: Automatic SSL certificate provisioning and HTTPS redirect
- **DNS Management**: Route 53 integration for custom domain
- **Security**: IAM roles for secure S3 access without hardcoded credentials
- **Monitoring**: Health checks and logging for all components

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate permissions
- Existing AWS Route 53 hosted zone for `zhemanov.link`
- Existing EC2 key pair named `eu-central-1` in the target region

## Quick Start

1. **Clone and navigate to the environment**:
   ```bash
   cd terra/aws/environments/immich
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Review and customize variables** in [`terraform.tfvars`](terraform.tfvars):
   ```hcl
   # Key configuration variables
   instance_type = "t3.medium"
   region = "eu-central-1"
   key_name = "eu-central-1"
   root_volume_size = 50
   
   # S3 and media sync configuration
   s3_mount_path = "/mnt/s3-immich-storage"
   enable_file_sync = true
   docker_media_directory = "/opt/immich-storage/media"
   ```

4. **Plan and apply**:
   ```bash
   terraform plan
   terraform apply
   ```

## Configuration

### Network Configuration
- **VPC CIDR**: `10.10.0.0/16`
- **Public Subnets**: `10.10.1.0/24`, `10.10.2.0/24`
- **Private Subnets**: `10.10.11.0/24`, `10.10.12.0/24`

### EC2 Configuration
- **Instance Type**: `t3.medium` (2 vCPU, 4GB RAM)
- **AMI**: Ubuntu 22.04 LTS (automatically selected by region)
- **Root Volume**: 50GB GP3 SSD
- **Key Pair**: `eu-central-1`

### S3 Integration
- **Bucket Structure**:
  - `photos/` - Photo storage
  - `videos/` - Video storage  
  - `backups/` - Backup storage
- **Mount Point**: `/mnt/s3-immich-storage`
- **Sync Source**: `/opt/immich-storage/media`

### SSL & DNS
- **Domain**: `photo.zhemanov.link`
- **SSL**: Automatic ACM certificate with DNS validation
- **Load Balancer**: HTTP to HTTPS redirect

## Post-Deployment Setup

After deployment, the infrastructure will output important connection details:

```bash
# SSH to the instance
terraform output ec2_ssh_command

# Access your Immich instance
terraform output https_subdomain_url
```