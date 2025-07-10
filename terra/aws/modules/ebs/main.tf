resource "aws_ebs_volume" "this" {
  availability_zone = var.availability_zone
  size              = var.size
  type              = var.type
  iops              = var.type == "gp3" || var.type == "io1" || var.type == "io2" ? var.iops : null
  throughput        = var.type == "gp3" ? var.throughput : null
  encrypted         = var.encrypted
  kms_key_id        = var.kms_key_id
  snapshot_id       = var.snapshot_id
  
  tags = merge(var.tags, {
    Name = var.name != null ? var.name : "${var.environment}-ebs-volume"
  })
}

resource "aws_volume_attachment" "this" {
  count = var.attach_to_instance ? 1 : 0
  
  device_name = var.device_name
  volume_id   = aws_ebs_volume.this.id
  instance_id = var.instance_id
}
