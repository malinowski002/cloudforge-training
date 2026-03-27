variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Default region for resources"
  type        = string
  default     = "europe-central2"
}

variable "ssl_certificate" {
  description = "SSL certificate content (PEM format)."
  type        = string
  sensitive   = true
}

variable "ssl_private_key" {
  description = "SSL private key content (PEM format)."
  type        = string
  sensitive   = true
}