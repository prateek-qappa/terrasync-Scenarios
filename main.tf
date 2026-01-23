terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket  = "bucket-qappa"
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




  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "terrasync-web-sg"
    Project     = "terrasync"
    "security " = "too Much secure"
  }
  ingress {
    security_groups  = []
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    self             = false
    description      = "Exeternal Drift"
    protocol         = "tcp"
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP"
    ipv6_cidr_blocks = []
    to_port          = 80
    from_port        = 80
    security_groups  = []
    self             = false
    protocol         = "tcp"
    prefix_list_ids  = []
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 443
    to_port          = 443
    description      = "HTTPS"
    security_groups  = []
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    self             = false
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    security_groups  = []
    self             = false
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = 22
    protocol         = "tcp"
    to_port          = 22
    description      = "SSH"
    prefix_list_ids  = []
    ipv6_cidr_blocks = []
  }
}

resource "aws_security_group" "test_sg" {
  name        = "terrasync-test-sg"
  description = "Allow SSH, HTTP, HTTPS, Mail"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Mail"
    from_port   = 143
    to_port     = 143
    protocol    = "udp"
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
    description = "HTTPS 500 waala"
    from_port   = 500
    to_port     = 500
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
    Name    = "terrasync-test-sg"
    Project = "terrasync"
  }
}

resource "aws_instance" "terrasync_2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name    = "terrasync-2"
    Project = "terrasync"
    Role    = "web"
    service = "delivery"
  }
}

resource "aws_instance" "Terra-SYNC-3" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.test_sg.id]

  tags = {
    Name    = "terrasync-3"
    Role    = "web-3-test"
    Project = "terrasync"
  }
}
/*
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
*/
