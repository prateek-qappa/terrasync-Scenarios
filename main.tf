# TerraSync Test Fixture - Basic AWS Infrastructure
# This file creates test resources to demonstrate drift detection

terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket = "test1-qappalabs"
    key    = "test"
    region = "ap-south-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Using skip_credentials_validation for testing without real AWS access
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  # Endpoints can be configured for LocalStack or mocked testing
  # endpoints {
  #   ec2 = "http://localhost:4566"
  #   s3  = "http://localhost:4566"
  # }
}

# Use Default VPC (no VPC creation allowed)
data "aws_vpc" "default" {
  default = true
}

# Use Default Subnet (no subnet creation allowed)
data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.aws_region}a"
  default_for_az    = true
}

# Security Group
resource "aws_security_group" "web" {
  name        = "terrasync-web-sg"
  description = "Security group for web servers"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "terrasync-web-sg"
    Environment = "development"
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = data.aws_subnet.default.id

  vpc_security_group_ids = [aws_security_group.web.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name        = "terrasync-web-server"
    Environment = "development"
    Application = "web"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "data" {
  bucket = var.bucket_name

  tags = {
    Name        = "terrasync-data-bucket"
    Environment = "development"
    Purpose     = "application-data"
  }
}
# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "state_bucket" {

}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
