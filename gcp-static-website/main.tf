resource "random_id" "bucket_suffix" {
  byte_length = 4
}

module "storage" {
  source          = "./modules/storage"
  bucket_name     = "static-website-${random_id.bucket_suffix.hex}"
  region          = "US"
  index_html_path = "index.html"
}

module "load_balancer" {
  source              = "./modules/load-balancer"
  backend_bucket_name = module.storage.bucket_name
}

output "website_url" {
  value = "http://${module.load_balancer.lb_ip_address}"
}