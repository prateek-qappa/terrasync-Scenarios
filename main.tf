terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket  = "dec30-qappa"
    key     = "global/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI for ap-south-1"
  default     = "ami-03f4878755434977f"
}

variable "instance_type" {
  default = "t2.micro"
}

resource "aws_security_group" "web_sg" {
  name        = "terrasync-web-sg"
  description = "Allow SSH, HTTP, HTTPS"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name    = "terrasync-web-sg"
    Project = "terrasync"
  }
}

resource "aws_instance" "terrasync_1" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name    = "terrasync-1"
    Role    = "web"
    Project = "terrasync"
  }
}

resource "aws_instance" "terrasync_2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name    = "terrasync-2"
    Role    = "web"
    Project = "terrasync"
  }
}

resource "aws_s3_bucket" "bucket_1" {
  bucket = "terrasync-test-bucket-1-12345"

  tags = {
    Name    = "terrasync-bucket-1"
    Project = "terrasync"
    Purpose = "testing"
  }
}

resource "aws_s3_bucket" "bucket_2" {
  bucket = "terrasync-test-bucket-2-12345"

  tags = {
    Name    = "terrasync-bucket-2"
    Project = "terrasync"
    Purpose = "testing"
  }
}
