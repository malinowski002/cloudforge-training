variable "backend_bucket_name" {
  description = "The name of the backend bucket"
  type        = string
}

variable "ssl_certificate" {
  description = "SSL certificate content (PEM format)."
  type        = string
  sensitive = true
}

variable "ssl_private_key" {
  description = "SSL private key content (PEM format)."
  type        = string
  sensitive   = true
}