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
  type      = string
  ephemeral = true
}

variable "ssl_private_key_path" {
  type      = string
  ephemeral = true
}