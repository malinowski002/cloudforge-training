variable "region" {
  description = "AWS region where the EKS cluster will be deployed."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the EKS VPC"
  type        = string
}

variable "azs" {
  type        = list(string)
  description = "Two AZs for public/private subnets"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
}

variable "bastion_instance_type" {
  type        = string
  description = "Instance type for the bastion host"
  default     = "t3.micro"
}