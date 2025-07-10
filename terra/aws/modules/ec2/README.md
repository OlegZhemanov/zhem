# EC2 Module with S3 Mount

This Terraform module creates an EC2 instance with optional S3 bucket mounting capability using s3fs-fuse.

## Features

- Creates an EC2 instance with Ubuntu 22.04 LTS
- Optional S3 bucket mounting using IAM roles (no hardcoded credentials)
- Automatic installation and configuration of s3fs-fuse
- Persistent mounting configuration via fstab

## Usage

### Basic EC2 Instance

```hcl
module "ec2" {
  source = "./modules/ec2"
  
  environment               = "dev"
  instance_type            = "t3.micro"
  key_name                 = "my-key-pair"
  subnet_id                = "subnet-12345"
  security_group_ids       = ["sg-12345"]
  
  tags = {
    Environment = "dev"
    Project     = "my-project"
  }
}
```

### EC2 Instance with S3 Mount and File Sync

```hcl
module "ec2_with_s3_advanced" {
  source = "./modules/ec2"
  
  environment               = "immich"
  instance_type            = "t3.medium"
  key_name                 = "my-key-pair"
  subnet_id                = "subnet-12345"
  security_group_ids       = ["sg-12345"]
  
  # S3 Mount Configuration
  s3_bucket_name           = "my-immich-storage"
  s3_mount_path            = "/mnt/immich-storage"
  s3_mount_prefix          = "photos"
  install_s3_mountpoint    = true  # Use S3 Mountpoint instead of s3fs
  
  # File Sync Configuration
  enable_file_sync         = true
  docker_media_directory   = "/opt/immich-storage/media"
  sync_file_types          = ["jpg", "jpeg", "png", "heic", "webp", "mp4", "mov"]
  remove_local_files       = false
  
  # External IAM instance profile (if using separate S3 module)
  iam_instance_profile     = "my-s3-instance-profile"
  
  tags = {
    Environment = "immich"
    Project     = "photo-storage"
  }
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Name of the environment | `string` | `"default"` | no |
| ami | AMI ID for the EC2 instance | `string` | `null` | no |
| instance_type | EC2 instance type | `string` | `"t2.micro"` | no |
| key_name | Key pair name for SSH access | `string` | `null` | no |
| subnet_id | Subnet ID to launch the instance in | `string` | n/a | yes |
| security_group_ids | List of security group IDs | `list(string)` | `[]` | no |
| associate_public_ip_address | Whether to associate a public IP address | `bool` | `true` | no |
| tags | Tags to apply to the instance | `map(string)` | `{}` | no |
| root_volume_size | Root volume size in GB | `number` | `8` | no |
| root_volume_type | Root volume type | `string` | `"gp2"` | no |
| enable_s3_mount | Whether to enable S3 mount point | `bool` | `false` | no |
| s3_bucket_name | S3 bucket name to mount | `string` | `""` | no |
| s3_mount_path | Local path where S3 bucket will be mounted | `string` | `"/mnt/s3"` | no |
| s3_mount_prefix | S3 bucket prefix to mount (optional) | `string` | `""` | no |
| iam_instance_profile | IAM instance profile name to attach to EC2 instance | `string` | `null` | no |
| install_s3_mountpoint | Whether to install and configure S3 Mountpoint | `bool` | `false` | no |
| enable_file_sync | Whether to enable automatic file sync to S3 | `bool` | `false` | no |
| docker_media_directory | Directory path where Docker containers will save media files | `string` | `"/opt/immich-storage/media"` | no |
| sync_file_types | List of file extensions to sync (without dots) | `list(string)` | `["jpg", "jpeg", "png", "heic", "webp", "mp4", "mov", "avi", "mkv"]` | no |
| remove_local_files | Whether to remove local files after successful S3 upload | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | The ID of the EC2 instance |
| public_ip | The public IP address of the EC2 instance |
| private_ip | The private IP address of the EC2 instance |
| ami_id | The AMI ID used for the EC2 instance |
| availability_zone | The availability zone of the EC2 instance |
| ssh_connection_command | SSH command to connect to the instance |
| s3_mount_enabled | Whether S3 mount is enabled |
| s3_bucket_name | S3 bucket name being mounted |
| s3_mount_point | S3 mount point on the instance |
| s3_mount_prefix | S3 bucket prefix being mounted |
| file_sync_enabled | Whether automatic file sync to S3 is enabled |
| iam_role_arn | ARN of the IAM role attached to the instance for S3 access |

## S3 Mount and File Sync Details

When S3 mounting or file sync is enabled, the module will:

1. **S3 Mounting Options:**
   - **s3fs-fuse**: Traditional FUSE-based mounting (default when `enable_s3_mount` is true)
   - **S3 Mountpoint**: AWS's new high-performance mounting solution (when `install_s3_mountpoint` is true)

2. **IAM Configuration:**
   - Create an IAM role with permissions to access the specified S3 bucket (when `enable_s3_mount` is true)
   - Use external IAM instance profile (when `iam_instance_profile` is provided)
   - Attach the IAM role to the EC2 instance via an instance profile

3. **Automatic Installation and Configuration:**
   - Install s3fs-fuse or S3 Mountpoint during instance boot
   - Mount the S3 bucket to the specified mount point
   - Configure the mount to persist across reboots (s3fs only)

4. **File Sync Service (when `enable_file_sync` is true):**
   - Create a systemd service that automatically syncs files from Docker media directory to S3
   - Run sync every 15 minutes via systemd timer
   - Support for filtering by file extensions
   - Optional removal of local files after successful upload
   - Comprehensive logging to `/var/log/s3-sync.log`

### Prerequisites

- The S3 bucket must exist before running this module
- The EC2 instance needs internet access to download packages
- The instance must be in a subnet that allows outbound HTTPS traffic
- For file sync: AWS CLI must be available (automatically installed)

### S3 Mount Performance Comparison

| Feature | s3fs-fuse | S3 Mountpoint |
|---------|-----------|---------------|
| Performance | Good for light workloads | Optimized for high throughput |
| POSIX Compliance | Full POSIX semantics | Limited POSIX semantics |
| Caching | Local file cache | Intelligent prefetching |
| Use Case | General purpose | High-performance applications |

### File Sync Features

- **Selective Sync**: Only sync specified file types
- **Incremental**: Only uploads new/changed files
- **Logging**: Detailed logs for troubleshooting
- **Configurable**: Customizable sync intervals and behavior
- **Docker Integration**: Designed for containerized applications

## Security Considerations

- The IAM role is scoped to access only the specified S3 bucket
- No AWS credentials are stored on the instance
- The role uses instance metadata service for authentication
- Consider using S3 bucket policies for additional access controls
