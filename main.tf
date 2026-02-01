# Sample Terraform configuration
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Optional: Configure backend
  # backend "s3" {
  #   bucket = "my-terraform-state"
  #   key    = "terraform.tfstate"
  #   region = "ap-southeast-2"
  # }
}

# Example: AWS provider
provider "aws" {
  region = "ap-southeast-2"

  # Credentials can be set via environment variables:
  # AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
}

resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "echo 'Hello, World!'"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "example" {
  bucket = "example-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "Example Bucket"
    Environment = "Demo"
    ManagedBy   = "Terraform"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access (security best practice)
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Output the bucket name and ARN
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.example.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.example.arn
}
