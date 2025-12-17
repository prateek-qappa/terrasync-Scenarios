# Simplified resource configuration (modules not used due to service restrictions)
# Tests TerraSync with organized EC2 and S3 resources
# Restricted to EC2 (micro instances) and S3 services only in ap-south-1

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data source for default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source for default subnet in AZ-a
data "aws_subnet" "default_a" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "ap-south-1a"
  default_for_az    = true
}

# Data source for default subnet in AZ-b (if available)
data "aws_subnet" "default_b" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "ap-south-1b"
  default_for_az    = true
}

# Security Group for Web Tier
resource "aws_security_group" "web_tier" {
  name        = "terrasync-web-tier-sg"
  description = "Security group for web tier"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terrasync-web-tier-sg"
    Tier = "web"
  }
}

# Web Tier - EC2 Instances
resource "aws_instance" "web_1" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnet.default_a.id

  vpc_security_group_ids = [aws_security_group.web_tier.id]

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  tags = {
    Name        = "terrasync-web-1"
    Environment = "dev"
    Tier        = "web"
    AZ          = "ap-south-1a"
  }
}

resource "aws_instance" "web_2" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnet.default_b.id

  vpc_security_group_ids = [aws_security_group.web_tier.id]

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  tags = {
    Name        = "terrasync-web-2"
    Environment = "dev"
    Tier        = "web"
    AZ          = "ap-south-1b"
  }
}

# S3 Bucket for Static Assets
resource "aws_s3_bucket" "static_assets" {
  bucket = "terrasync-static-assets-12345"

  tags = {
    Name        = "terrasync-static-assets"
    Environment = "dev"
    Purpose     = "static-web-content"
  }
}

# S3 Bucket for User Uploads
resource "aws_s3_bucket" "uploads" {
  bucket = "terrasync-uploads-12345"

  tags = {
    Name        = "terrasync-uploads"
    Environment = "dev"
    Purpose     = "user-uploads"
  }
}

# Versioning for Static Assets
resource "aws_s3_bucket_versioning" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Public Access Block for Uploads
resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CORS Configuration for Uploads
resource "aws_s3_bucket_cors_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

# This demonstrates organized infrastructure using only EC2 and S3
# Previously used modules, but simplified due to service restrictions
