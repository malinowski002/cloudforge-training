resource "random_id" "bucket_suffix" {
  byte_length = 4
}

module "storage" {
  source          = "./modules/storage"
  bucket_name     = "static-website-${random_id.bucket_suffix.hex}"
  region          = "US"
  index_html_path = "index.html"
  error_404_html_path = "error_404.html"
  error_5xx_html_path = "error_5xx.html"
}

module "load_balancer" {
  source              = "./modules/load-balancer"
  backend_bucket_name = module.storage.bucket_name
  ssl_certificate_path = var.ssl_certificate_path
  ssl_certificate_private_key_path = var.ssl_private_key_path
}

output "website_url" {
  value = "https://${module.load_balancer.lb_ip_address}"
}