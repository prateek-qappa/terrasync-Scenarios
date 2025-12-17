# TerraSync Test Fixtures

This directory contains Terraform configurations for testing TerraSync features.

## AWS Service Restrictions

**IMPORTANT**: These test fixtures are configured with the following restrictions:
- **Allowed Services**: EC2 and S3 only
- **EC2 Instance Types**: Micro instances only (t2.micro, t3.micro)
- **Region**: Mumbai (ap-south-1) only
- **VPC**: Uses default VPC (no custom VPC creation)

## Test Scenarios

### Scenario 1: Basic Resource Creation
**Purpose**: Test basic code parsing and state loading
**Files**: `main.tf`, `variables.tf`, `outputs.tf`

Resources created:
- Default VPC data source (no creation)
- Default Subnet data source (no creation)
- Security group with HTTP/HTTPS ingress (in default VPC)
- EC2 instance (t3.micro in ap-south-1)
- S3 bucket with versioning and public access block

**Total Managed Resources**: 5
- 1 Security Group
- 1 EC2 Instance
- 1 S3 Bucket
- 1 S3 Bucket Versioning config
- 1 S3 Public Access Block

### Scenario 2: Configuration Drift (DRIFT_CONFIG)
**Purpose**: Test detection of code changes not yet applied
**File**: `scenarios/drift-config.tf`

**Steps to simulate**:
1. Apply the initial configuration
2. Modify `instance_type` in drift-config.tf from `t3.micro` to `t2.micro`
3. Run `terrasync resolve`

**Expected**: TerraSync should show `DRIFT_CONFIG` for aws_instance.web_modified

### Scenario 3: External Drift (DRIFT_EXTERNAL)
**Purpose**: Test detection of manual changes made outside Terraform

**Steps to simulate**:
1. Apply the initial configuration
2. Manually modify the security group in AWS Console (add a new ingress rule)
3. Run `terrasync resolve`

**Expected**: TerraSync should show `DRIFT_EXTERNAL` for aws_security_group.web

### Scenario 4: State Drift (DRIFT_STATE)
**Purpose**: Test state vs deployed differences

**Steps to simulate**:
1. Apply the initial configuration
2. Manually modify terraform.tfstate file (change instance type)
3. Run `terrasync resolve`

**Expected**: TerraSync should show `DRIFT_STATE`

### Scenario 5: Three-Way Conflict (CONFLICT)
**Purpose**: Test complex scenario where all three sources differ

**Steps to simulate**:
1. Apply initial configuration
2. Change instance_type in code to `t2.micro`
3. Manually change instance type in AWS to `t3a.micro`
4. State still shows `t3.micro`
5. Run `terrasync resolve`

**Expected**: TerraSync should show `CONFLICT` with all three versions displayed

### Scenario 6: Multi-Resource Test
**Purpose**: Test TerraSync with multiple EC2 and S3 resources
**File**: `scenarios/multi-resource.tf`

Resources created:
- 1 Additional Security Group
- 2 EC2 Instances (app_server_1, app_server_2)
- 2 S3 Buckets (logs, backups)
- S3 versioning for both buckets
- S3 lifecycle configuration
- S3 public access blocks

**Total Managed Resources**: 9

### Scenario 7: Organized Infrastructure
**Purpose**: Test organized resource structure (previously used modules)
**File**: `scenarios/modules-example.tf`

Resources created:
- 1 Web Tier Security Group
- 2 Web Tier EC2 Instances (multi-AZ in ap-south-1a and ap-south-1b)
- 2 S3 Buckets (static assets, uploads)
- S3 versioning, public access block, and CORS configuration

**Total Managed Resources**: 9

## Using with LocalStack

For local testing without AWS credentials:

```bash
# Start LocalStack
docker run -d -p 4566:4566 localstack/localstack

# Configure endpoints in main.tf provider block (uncomment the endpoints section)

# Run terraform
terraform init
terraform apply
```

## Testing TerraSync Commands

### Test Code Loader
```bash
cd /home/prateek/workDir/terrasync
go run main.go resolve --output test-output.json
```

This should parse the .tf files in test-fixtures/ and display resources.

### Test State Loader
```bash
# First initialize and apply
cd test-fixtures
terraform init
terraform apply -auto-approve

# Then run TerraSync
cd ..
go run main.go resolve
```

### Test Deployed Loader
```bash
# After resources are created, modify something manually
# Then run TerraSync to detect drift
go run main.go resolve
```

## Configuration Notes

### Region and AMI
- **Region**: ap-south-1 (Mumbai)
- **AMI**: ami-0f58b397bc5c1f2e8 (Amazon Linux 2023 for Mumbai region)
- Update the AMI ID if you need a different OS or if the AMI is deprecated

### Instance Types
Only micro instance types are permitted:
- `t2.micro` - Previous generation, burstable
- `t3.micro` - Current generation, burstable
- `t3a.micro` - AMD-based variant

### S3 Bucket Names
S3 bucket names must be globally unique. Update the following variables/values:
- `bucket_name` in variables.tf
- Bucket names in scenario files (add unique suffixes)

### Default VPC
These configurations use the default VPC in ap-south-1. Ensure:
1. Default VPC exists in your account
2. Default subnets are available in ap-south-1a and ap-south-1b
3. If default VPC doesn't exist, you can create one via AWS Console

## Provider Configuration

The provider is configured with skip flags for testing:
```hcl
skip_credentials_validation = true
skip_requesting_account_id  = true
skip_metadata_api_check     = true
```

For real AWS testing:
1. Remove the skip flags from main.tf
2. Configure AWS credentials via:
   - AWS CLI (`aws configure`)
   - Environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
   - IAM role (if running on EC2)

## Resource Limits

Due to service restrictions, the following resources are **NOT** available:
- ❌ Custom VPCs, Subnets, Internet Gateways, NAT Gateways
- ❌ Application Load Balancers (ALB), Network Load Balancers (NLB)
- ❌ RDS Databases
- ❌ Lambda Functions
- ❌ ECS/EKS Clusters
- ❌ CloudFront Distributions
- ❌ Route53 Hosted Zones
- ✅ EC2 Instances (micro types only)
- ✅ EC2 Security Groups (in default VPC)
- ✅ S3 Buckets and configurations

## Troubleshooting

### AMI Not Found
If you get an AMI not found error, the AMI ID may be outdated. Find a current AMI:
```bash
aws ec2 describe-images \
  --region ap-south-1 \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query 'Images[*].[ImageId,CreationDate]' \
  --output text | sort -k2 -r | head -n 1
```

### Default VPC Not Found
If the default VPC doesn't exist:
1. Create one via AWS Console: VPC → Actions → Create Default VPC
2. Or use AWS CLI:
```bash
aws ec2 create-default-vpc --region ap-south-1
```

### Bucket Name Conflicts
S3 bucket names must be globally unique. If you get a conflict:
1. Update `bucket_name` in variables.tf with a unique suffix
2. Update bucket names in scenario files with unique identifiers
