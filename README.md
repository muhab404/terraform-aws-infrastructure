# AWS Web Application Infrastructure with Terraform

This project provisions a complete AWS infrastructure for a web application using Terraform, including VPC, EC2, RDS PostgreSQL, Lambda, API Gateway, and Route 53.

## Architecture Overview

The infrastructure includes:
- **VPC** with public and private subnets
- **EC2 instance** in private subnet with IAM role for S3 access
- **Application Load Balancer** for routing traffic to the private EC2 instance
- **RDS PostgreSQL** database with encryption enabled
- **Lambda function** that interacts with the database
- **API Gateway** with REST API routing to Lambda
- **Route 53** for custom domain management
- **S3 bucket** with encryption enabled
- **S3 backend** for storing Terraform state
- **Security groups** allowing HTTP/SSH access

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** installed (version >= 1.0)
3. **AWS Account** with necessary permissions

## Project Structure

```
terraform-aws-infrastructure/
├── main.tf                    # Main configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── README.md                  # This file
└── modules/
    ├── vpc/                   # VPC module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/                   # EC2 module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── alb/                   # ALB module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── rds/                   # RDS module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── lambda/                # Lambda module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── api-gateway/           # API Gateway module
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Setup Instructions

### 1. Clone and Navigate
```bash
cd terraform-aws-infrastructure
```

### 2. Set Up S3 Backend
Before running Terraform, create an S3 bucket and DynamoDB table for the backend:

```bash
# Create S3 bucket for Terraform state
aws s3api create-bucket --bucket terraform-state-bucket-unique-12345 --region us-east-1

# Enable versioning on the bucket
aws s3api put-bucket-versioning --bucket terraform-state-bucket-unique-12345 --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-lock-table \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### 3. Configure Variables
Edit `variables.tf` or create a `terraform.tfvars` file:
```hcl
aws_region = "us-east-1"
project_name = "webapp"
domain_name = "yourdomain.com"
s3_bucket_name = "your-unique-bucket-name"
db_password = "YourSecurePassword123!"
```

### 4. Initialize Terraform
```bash
terraform init
```

### 5. Plan Deployment
```bash
terraform plan
```

### 6. Deploy Infrastructure
```bash
terraform apply
```
Type `yes` when prompted to confirm.

## Important Notes

### Security Considerations
- **Database Password**: Change the default password in `variables.tf`
- **S3 Bucket Name**: Must be globally unique
- **Domain Name**: Update to your actual domain for Route 53

### Lambda Dependencies
The Lambda function requires the `psycopg2` library for PostgreSQL connectivity. In production, you should:
1. Create a Lambda layer with `psycopg2`
2. Package the function with dependencies

### Route 53 Domain
- The Route 53 hosted zone will be created
- Update your domain's nameservers to point to AWS Route 53
- The API will be accessible at `api.yourdomain.com`

## Testing the Deployment

### 1. Test Web Application via ALB
```bash
http://<alb_dns_name>
```

### 2. Test API Gateway
```bash
curl https://your-api-id.execute-api.region.amazonaws.com/prod/db
```

### 3. Test Lambda Function
The Lambda function connects to PostgreSQL and returns the database version.

### 4. Verify Resources
Check the AWS Console to verify all resources are created:
- VPC with subnets
- EC2 instance running
- Application Load Balancer
- RDS PostgreSQL instance
- Lambda function
- API Gateway deployment
- Route 53 hosted zone

## Outputs

After successful deployment, you'll see:
- VPC and subnet IDs
- EC2 instance ID
- ALB DNS name
- RDS endpoint
- API Gateway URL
- Route 53 zone ID
- S3 bucket name

## Cleanup Instructions

### Destroy Infrastructure
```bash
terraform destroy
```
Type `yes` when prompted to confirm.

### Manual Cleanup (if needed)
Some resources might need manual cleanup:
1. Empty S3 bucket before destruction
2. Check for any remaining ENIs or security groups
3. Verify Route 53 hosted zone deletion


### Logs and Monitoring
- **Lambda Logs**: CloudWatch Logs
- **API Gateway Logs**: Enable in API Gateway settings


