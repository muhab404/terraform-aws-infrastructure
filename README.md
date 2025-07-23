# Terraform AWS Infrastructure

This project provisions a complete AWS infrastructure for a web application using Terraform. The infrastructure includes VPC, EC2 instances, RDS database, Lambda functions, API Gateway, Load Balancer, and more.

## Architecture Overview

The infrastructure follows a multi-tier architecture pattern with the following components:

### Network Layer
- **VPC**: Custom Virtual Private Cloud (10.0.0.0/16)
- **Subnets**: 
  - 2 Public subnets (10.0.1.0/24, 10.0.3.0/24) across different AZs
  - 2 Private subnets (10.0.2.0/24, 10.0.4.0/24) across different AZs
- **Internet Gateway**: For public internet access
- **NAT Gateway**: For private subnet internet access
- **Route Tables**: Proper routing configuration

### Compute Layer
- **EC2 Instance**: Application server in private subnet
- **Bastion Host**: Jump server in public subnet for secure SSH access
- **Lambda Functions**: Serverless compute for API operations

### Storage Layer
- **RDS MySQL**: Managed database in private subnet with Multi-AZ setup
- **S3 Bucket**: Object storage 

### Load Balancing & API
- **Application Load Balancer (ALB)**: Distributes traffic across instances
- **API Gateway**: RESTful API endpoint management
- **Route53**: DNS management and domain routing

### Security
- **Security Groups**: Network-level security rules
- **IAM Roles**: Proper access permissions for services


## Architecture Diagram

```
Internet
    |
[Internet Gateway]
    |
[Public Subnets] - [ALB] - [Bastion Host]
    |
[NAT Gateway]
    |
[Private Subnets] - [EC2 Instance] - [RDS]

```

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **AWS Account** with necessary permissions
4. **Domain** registered (for Route53 configuration)
5. **S3 Backend** bucket and DynamoDB table for state management

### Required AWS Permissions
- EC2 (full access)
- VPC (full access)
- RDS (full access)
- Lambda (full access)
- API Gateway (full access)
- Route53 (full access)
- S3 (full access)
- IAM (full access)

## Setup Instructions

### 1. Clone and Navigate
```bash
git clone <repository-url>
cd terraform-aws-infrastructure
```

### 2. Configure Backend (First Time Setup)
Create the S3 bucket and DynamoDB table for Terraform state:

```bash
# Create S3 bucket for state
aws s3 mb s3://terraform-state-bucket-unique-12345 --region us-east-1

# Create DynamoDB table for state locking
aws dynamodb create-table \
    --table-name terraform-lock-table \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region us-east-1
```

### 3. Create EC2 Key Pair
```bash
# Create key pair for EC2 access
aws ec2 create-key-pair --key-name my-webapp-keypair --query 'KeyMaterial' --output text > my-webapp-keypair.pem
chmod 400 my-webapp-keypair.pem
```

### 4. Initialize Terraform
```bash
terraform init
```

### 5. Plan Infrastructure
```bash
terraform plan
```

### 6. Deploy Infrastructure
```bash
terraform apply
```

When prompted, type `yes` to confirm the deployment.

### 7. Verify Deployment
After successful deployment, you'll see outputs including:
- VPC ID
- EC2 Instance ID
- RDS Endpoint
- API Gateway URL
- Load Balancer DNS Name
- Bastion Host Public IP

## Configuration Variables

Key variables can be customized in `variables.tf`:

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | us-east-1 |
| `project_name` | Project name prefix | webapp |
| `vpc_cidr` | VPC CIDR block | 10.0.0.0/16 |
| `db_username` | Database username | dbadmin |
| `db_password` | Database password | ChangeMe123! |
| `domain_name` | Route53 domain | muhab.site |
| `s3_bucket_name` | S3 bucket name | webapp-bucket-unique-12345 |
| `key_name` | EC2 key pair name | my-webapp-keypair |

### Custom Variables File
Create `terraform.tfvars` for custom values:
```hcl
aws_region = "us-west-2"
project_name = "my-webapp"
db_password = "MySecurePassword123!"
domain_name = "example.com"
```

## Accessing Resources

### SSH to EC2 Instance (via Bastion)
```bash
# SSH to bastion host
ssh -i my-webapp-keypair.pem ec2-user@<bastion-public-ip>

# From bastion, SSH to private EC2
ssh -i my-webapp-keypair.pem ec2-user@<private-ec2-ip>
```

### Database Connection
```bash
# Connect to RDS from EC2 instance
mysql -h <rds-endpoint> -u dbadmin -p
```


## Teardown Instructions

### 1. Destroy Infrastructure
```bash
terraform destroy
```

When prompted, type `yes` to confirm the destruction.

### 2. Clean Up Backend Resources (Optional)
```bash
# Delete S3 bucket (remove all objects first)
aws s3 rm s3://terraform-state-bucket-unique-12345 --recursive
aws s3 rb s3://terraform-state-bucket-unique-12345

# Delete DynamoDB table
aws dynamodb delete-table --table-name terraform-lock-table --region us-east-1
```

### 3. Remove Key Pair
```bash
# Delete key pair from AWS
aws ec2 delete-key-pair --key-name my-webapp-keypair

# Remove local key file
rm my-webapp-keypair.pem
```


## Security Considerations

- Database is in private subnet with no direct internet access
- Bastion host provides secure SSH access
- Security groups follow principle of least privilege
- RDS encryption at rest enabled
- S3 bucket versioning and encryption enabled
- IAM roles with minimal required permissions



## Module Structure

```
modules/
├── vpc/          # VPC, subnets, gateways, security groups
├── ec2/          # EC2 instances and related resources
├── rds/          # RDS database configuration
├── lambda/       # Lambda functions
├── api-gateway/  # API Gateway setup
├── alb/          # Application Load Balancer
├── bastion/      # Bastion host configuration
├── s3/           # S3 bucket setup
└── route53/      # DNS configuration
```

Each module contains:
- `main.tf` - Resource definitions
- `variables.tf` - Input variables
- `outputs.tf` - Output values

---

**Note**: Always review and customize the configuration according to your specific requirements before deployment. Ensure proper backup and disaster recovery procedures are in place for production environments.