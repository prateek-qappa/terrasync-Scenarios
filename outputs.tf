# Outputs for TerraSync Test Fixtures

output "security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.data.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.data.arn
}
