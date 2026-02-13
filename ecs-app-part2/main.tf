data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_a = data.aws_availability_zones.available.names[0]
  az_b = data.aws_availability_zones.available.names[1]
}

module "vpc" {
  source = "./modules/vpc"

  name       = "app"
  cidr_block = "10.0.0.0/16"

  public_subnets = [
    { name = "public-subnet-a", cidr = "10.0.0.0/24", az = local.az_a },
    { name = "public-subnet-b", cidr = "10.0.2.0/24", az = local.az_b },
  ]

  private_subnets = [
    { name = "private-subnet-a", cidr = "10.0.1.0/24", az = local.az_a },
    { name = "private-subnet-b", cidr = "10.0.3.0/24", az = local.az_b },
  ]
}
