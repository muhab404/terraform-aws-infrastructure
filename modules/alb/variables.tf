
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet"
  type        = string
}

variable "public_subnet_2_id" {
  description = "ID of the second public subnet"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID of the security group for ALB"
  type        = string
}

variable "instance_id" {
  description = "ID of the EC2 instance to attach to the target group"
  type        = string
}


