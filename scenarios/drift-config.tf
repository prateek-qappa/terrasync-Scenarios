# Scenario: DRIFT_CONFIG - Code changes not yet applied
# This demonstrates planned changes that haven't been applied to infrastructure

# Modified version of the web instance with different configuration
resource "aws_instance" "web_modified" {
  ami           = "ami-0f58b397bc5c1f2e8"  # Mumbai region AMI
  instance_type = "t2.micro"  # Changed from t3.micro (simulating drift)
  subnet_id     = data.aws_subnet.default.id

  vpc_security_group_ids = [aws_security_group.web.id]

  root_block_device {
    volume_size = 30  # Changed from 20
    volume_type = "gp3"
  }

  monitoring = true  # Added monitoring

  tags = {
    Name        = "terrasync-web-server"
    Environment = "production"  # Changed from development
    Application = "web"
    Version     = "v2"  # Added version tag
  }
}

# Modified S3 bucket with encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
