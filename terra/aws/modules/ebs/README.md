# EBS Module

This Terraform module creates an Amazon EBS (Elastic Block Store) volume and optionally attaches it to an EC2 instance.

## Features

- Creates EBS volumes with configurable size, type, and performance characteristics
- Supports all EBS volume types (gp2, gp3, io1, io2, st1, sc1)
- Optional encryption with customer-managed KMS keys
- Automatic attachment to EC2 instances
- Flexible device naming

## Usage

```hcl
module "ebs" {
  source = "./modules/ebs"

  environment       = "production"
  name              = "data-volume"
  availability_zone = "us-west-2a"
  size              = 500
  type              = "gp3"
  iops              = 3000
  throughput        = 125
  encrypted         = true
  
  # Attachment configuration
  attach_to_instance = true
  instance_id        = "i-1234567890abcdef0"
  device_name        = "/dev/xvdf"
  
  tags = {
    Environment = "production"
    Purpose     = "data-storage"
  }
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | `string` | `"default"` | no |
| name | Name for the EBS volume | `string` | `null` | no |
| availability_zone | Availability zone for the EBS volume | `string` | n/a | yes |
| size | Size of the EBS volume in GB | `number` | `100` | no |
| type | Type of EBS volume | `string` | `"gp3"` | no |
| iops | IOPS for the volume (gp3, io1, io2 only) | `number` | `null` | no |
| throughput | Throughput for gp3 volumes in MB/s | `number` | `null` | no |
| encrypted | Whether to encrypt the EBS volume | `bool` | `true` | no |
| kms_key_id | KMS key ID for encryption | `string` | `null` | no |
| snapshot_id | Snapshot ID to create volume from | `string` | `null` | no |
| attach_to_instance | Whether to attach to an EC2 instance | `bool` | `true` | no |
| instance_id | EC2 instance ID to attach to | `string` | `null` | no |
| device_name | Device name for attachment | `string` | `"/dev/xvdf"` | no |
| tags | Tags to apply to the EBS volume | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| volume_id | ID of the EBS volume |
| volume_arn | ARN of the EBS volume |
| volume_size | Size of the EBS volume |
| volume_type | Type of the EBS volume |
| volume_iops | IOPS of the EBS volume |
| volume_throughput | Throughput of the EBS volume |
| volume_encrypted | Whether the EBS volume is encrypted |
| volume_kms_key_id | KMS key ID used for encryption |
| availability_zone | Availability zone of the EBS volume |
| attachment_id | ID of the volume attachment |
| attachment_device_name | Device name of the attachment |
| attachment_instance_id | Instance ID of the attachment |

## Volume Types

### GP3 (General Purpose SSD v3)
- Default choice for most workloads
- 3,000 IOPS baseline, can be provisioned up to 16,000 IOPS
- 125 MB/s baseline throughput, can be provisioned up to 1,000 MB/s

### GP2 (General Purpose SSD v2)
- Legacy general purpose option
- IOPS scale with volume size (3 IOPS per GB, up to 16,000 IOPS)

### IO1/IO2 (Provisioned IOPS SSD)
- High-performance option for I/O intensive workloads
- Can provision up to 64,000 IOPS
- IO2 offers better durability than IO1

### ST1 (Throughput Optimized HDD)
- For frequently accessed, large datasets
- Cannot be used as boot volume

### SC1 (Cold HDD)
- Lowest cost option
- For infrequently accessed data
- Cannot be used as boot volume

## Device Names

When attaching EBS volumes to Linux instances, use:
- `/dev/xvdf` through `/dev/xvdz` for additional volumes
- `/dev/xvdba` through `/dev/xvdbz` for more volumes

Note: The actual device name in the OS may appear as `/dev/nvme*` on newer instance types.

## Post-Deployment Setup

After the EBS volume is attached, you'll need to:

1. **Format the volume** (first time only):
   ```bash
   sudo mkfs.ext4 /dev/xvdf
   ```

2. **Create a mount point**:
   ```bash
   sudo mkdir -p /mnt/ebs-data
   ```

3. **Mount the volume**:
   ```bash
   sudo mount /dev/xvdf /mnt/ebs-data
   ```

4. **Add to fstab for persistent mounting**:
   ```bash
   echo '/dev/xvdf /mnt/ebs-data ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab
   ```

5. **Set appropriate permissions**:
   ```bash
   sudo chown ubuntu:ubuntu /mnt/ebs-data
   ```

## Best Practices

1. **Enable encryption** for sensitive data
2. **Choose appropriate volume type** based on workload requirements
3. **Size volumes appropriately** - consider future growth
4. **Use snapshots** for backup and disaster recovery
5. **Monitor performance** and adjust IOPS/throughput as needed
6. **Use lifecycle policies** to manage snapshots and reduce costs
