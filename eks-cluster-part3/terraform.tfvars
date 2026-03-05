region = "eu-central-1"

vpc_cidr             = "10.50.0.0/16"
azs                  = ["eu-central-1a", "eu-central-1b"]
public_subnet_cidrs  = ["10.50.1.0/24", "10.50.2.0/24"]
private_subnet_cidrs = ["10.50.11.0/24", "10.50.12.0/24"]

bastion_instance_type = "t3.micro"