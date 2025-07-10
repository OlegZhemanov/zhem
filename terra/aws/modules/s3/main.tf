provider "aws" {
  alias  = "s3_region"
  region = var.region
}

resource "aws_s3_bucket" "this" {
  provider = aws.s3_region
  bucket   = var.bucket_name
  
  tags = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  provider = aws.s3_region
  bucket   = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  provider = aws.s3_region
  bucket   = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  provider = aws.s3_region
  bucket   = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

# IAM role for EC2 to write to S3
resource "aws_iam_role" "s3_access_role" {
  provider = aws.s3_region
  count    = var.create_ec2_role ? 1 : 0
  name     = "${var.bucket_name}-s3-write-role"

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

resource "aws_iam_role_policy" "s3_access_policy" {
  provider = aws.s3_region
  count    = var.create_ec2_role ? 1 : 0
  name     = "${var.bucket_name}-s3-write-policy"
  role     = aws_iam_role.s3_access_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${aws_s3_bucket.this.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.this.arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "s3_access_profile" {
  provider = aws.s3_region
  count    = var.create_ec2_role ? 1 : 0
  name     = "${var.bucket_name}-s3-write-profile"
  role     = aws_iam_role.s3_access_role[0].name
  
  tags = var.tags
}

# Create prefix directories in S3 bucket
resource "aws_s3_object" "bucket_prefixes" {
  provider = aws.s3_region
  for_each = toset(var.bucket_prefixes)
  
  bucket        = aws_s3_bucket.this.id
  key           = each.value
  content       = ""
  content_type  = "application/x-directory"
  
  tags = var.tags
}
