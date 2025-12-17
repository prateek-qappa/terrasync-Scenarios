# Multi-resource test scenario
# Tests TerraSync with multiple EC2 and S3 resources
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

# Data source for default subnet
data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "ap-south-1a"
  default_for_az    = true
}

# Additional Security Group for App Servers
resource "aws_security_group" "app" {
  name        = "terrasync-app-sg"
  description = "Security group for app servers"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Custom app port"
    from_port   = 8080
    to_port     = 8080
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
    Name        = "terrasync-app-sg"
    Environment = "development"
  }
}

# Multiple EC2 Instances
resource "aws_instance" "app_server_1" {
  ami           = "ami-0f58b397bc5c1f2e8"  # Mumbai AMI
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnet.default.id

  vpc_security_group_ids = [aws_security_group.app.id]

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name        = "terrasync-app-server-1"
    Environment = "development"
    Role        = "application"
  }
}

resource "aws_instance" "app_server_2" {
  ami           = "ami-0f58b397bc5c1f2e8"  # Mumbai AMI
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet.default.id

  vpc_security_group_ids = [aws_security_group.app.id]

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  tags = {
    Name        = "terrasync-app-server-2"
    Environment = "development"
    Role        = "application"
  }
}

# Multiple S3 Buckets
resource "aws_s3_bucket" "logs" {
  bucket = "terrasync-logs-bucket-12345"

  tags = {
    Name        = "terrasync-logs-bucket"
    Environment = "development"
    Purpose     = "application-logs"
  }
}

resource "aws_s3_bucket" "backups" {
  bucket = "terrasync-backups-bucket-12345"

  tags = {
    Name        = "terrasync-backups-bucket"
    Environment = "development"
    Purpose     = "backups"
  }
}

# S3 Bucket Versioning for Logs
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Versioning for Backups
resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Lifecycle for Logs
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}

# S3 Public Access Block for Logs
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Public Access Block for Backups
resource "aws_s3_bucket_public_access_block" "backups" {
  bucket = aws_s3_bucket.backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
