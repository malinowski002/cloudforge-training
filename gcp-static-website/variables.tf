variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Default region for resources"
  type        = string
  default     = "europe-central2"
}

variable "ssl_certificate_path" {
  description = "Path to the SSL certificate file (PEM format)"
  type        = string
}

variable "ssl_private_key_path" {
  description = "Path to the SSL certificate private key file (PEM format)"
  type        = string
}