module "vpc" {
  source = "./modules/vpc"

  name = "k8s-payment-vpc"
  cidr = "10.20.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  public_subnets  = ["10.20.0.0/20", "10.20.16.0/20", "10.20.32.0/20"]
  private_subnets = ["10.20.64.0/20", "10.20.80.0/20", "10.20.96.0/20"]
}

module "rds" {
  source = "./modules/rds"

  name                = "payments-db"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  allowed_cidr_blocks = ["10.20.0.0/16"]

  db_name     = "payments"
  db_username = "payments"
}