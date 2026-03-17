output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "rds_master_secret_arn" {
  value = module.rds.master_secret_arn
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "ec2_postgres_private_ip" {
  value = module.ec2_postgres.private_ip
}