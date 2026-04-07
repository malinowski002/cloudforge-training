provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Ensure Compute Engine API is enabled (no-op if already enabled)
resource "google_project_service" "compute_api" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}
