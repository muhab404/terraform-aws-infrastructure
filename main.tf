terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  project_name          = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidr  = var.private_subnet_cidr
  public_subnet_2_cidr = var.public_subnet_2_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
  availability_zone    = data.aws_availability_zones.available.names[0]
  availability_zone_2  = data.aws_availability_zones.available.names[1]
}

# S3 Module
module "s3" {
  source = "./modules/s3"
  
  s3_bucket_name = var.s3_bucket_name
}

# Bastion Module
module "bastion" {
  source = "./modules/bastion"
  
  project_name      = var.project_name
  public_subnet_id  = module.vpc.public_subnet_id
  security_group_id = module.vpc.bastion_security_group_id
  key_name          = var.key_name
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"
  
  project_name      = var.project_name
  private_subnet_id = module.vpc.private_subnet_id
  security_group_id = module.vpc.ec2_security_group_id
  key_name          = var.key_name
  s3_bucket_arn     = module.s3.bucket_arn
}

# ALB Module
module "alb" {
  source = "./modules/alb"
  
  project_name         = var.project_name
  vpc_id               = module.vpc.vpc_id
  public_subnet_id     = module.vpc.public_subnet_id
  public_subnet_2_id   = module.vpc.public_subnet_2_id
  alb_security_group_id = module.vpc.alb_security_group_id
  instance_id          = module.ec2.instance_id
}


# RDS Module
module "rds" {
  source = "./modules/rds"
  
  project_name         = var.project_name
  private_subnet_id    = module.vpc.private_subnet_id
  private_subnet_2_id  = module.vpc.private_subnet_2_id
  security_group_id    = module.vpc.rds_security_group_id
  db_username         = var.db_username
  db_password         = var.db_password
}

# Lambda Module
module "lambda" {
  source = "./modules/lambda"
  
  project_name      = var.project_name
  private_subnet_id = module.vpc.private_subnet_id
  security_group_id = module.vpc.lambda_security_group_id
  db_endpoint      = module.rds.db_endpoint
  db_username      = var.db_username
  db_password      = var.db_password
}

# API Gateway Module
module "api_gateway" {
  source = "./modules/api-gateway"
  
  project_name      = var.project_name
  lambda_invoke_arn = module.lambda.lambda_invoke_arn
  lambda_function_name = module.lambda.lambda_function_name
}

# Route53 Module
module "route53" {
  source = "./modules/route53"
  
  domain_name     = var.domain_name
  api_domain_name = module.api_gateway.api_domain_name
}