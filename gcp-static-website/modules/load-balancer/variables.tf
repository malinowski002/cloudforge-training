variable "backend_bucket_name" {
  description = "The name of the backend bucket"
  type        = string
}

variable "ssl_certificate_path" {
  description = "Path to SSL certificate file (PEM format)"
  type        = string
}

variable "ssl_private_key_path" {
  description = "Path to SSL private key file (PEM format)"
  type        = string
}