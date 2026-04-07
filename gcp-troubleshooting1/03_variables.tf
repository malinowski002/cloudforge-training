variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "region" {
  type        = string
  description = "Region, e.g., europe-central2."
  default     = "europe-central2"
}

variable "zone" {
  type        = string
  description = "Zone, e.g., europe-central2-a."
  default     = "europe-central2-a"
}

variable "name" {
  type        = string
  description = "Resource name prefix."
  default     = "nginx-lab"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR block for the custom subnet."
  default     = "10.20.0.0/24"
}

variable "machine_type" {
  type        = string
  description = "Compute Engine machine type."
  default     = "e2-micro"
}

variable "ssh_source_cidr" {
  type        = string
  description = "Trusted CIDR for SSH access (use /32 for a single IP)."
}
