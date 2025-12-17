# Variables for TerraSync Test Fixtures

variable "aws_region" {
  description = "AWS region for test resources"
  type        = string
  default     = "ap-south-1"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance (region-specific)"
  type        = string
  default     = "ami-0f58b397bc5c1f2e8"  # Amazon Linux 2023 for ap-south-1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "bucket_name" {
  description = "S3 bucket name (must be globally unique)"
  type        = string
  default     = "terrasync-test-bucket-12345"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}
