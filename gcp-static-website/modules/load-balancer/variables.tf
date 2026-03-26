variable "backend_bucket_name" {
  description = "The name of the backend bucket"
  type        = string
}

variable "ssl_certificate_path" {
  description = "Path to the SSL certificate file (PEM format)"
  type        = string
}

variable "ssl_certificate_private_key_path" {
  description = "Path to the SSL certificate private key file (PEM format)"
  type        = string
}