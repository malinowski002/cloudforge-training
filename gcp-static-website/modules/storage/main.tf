resource "google_storage_bucket" "website" {
  name                        = var.bucket_name
  location                    = var.region
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
  }

}

resource "google_storage_bucket_iam_binding" "public_read" {
  bucket  = google_storage_bucket.website.name
  role    = "roles/storage.legacyObjectReader"
  members = ["allUsers"]
}

resource "google_storage_bucket_object" "index_html" {
  bucket = google_storage_bucket.website.name
  name   = "index.html"
  source = var.index_html_path
}

resource "google_storage_bucket_object" "error_404_html" {
  bucket = google_storage_bucket.website.name
  name   = "error_404.html"
  source = var.error_404_html_path
}

resource "google_storage_bucket_object" "error_5xx_html" {
  bucket = google_storage_bucket.website.name
  name   = "error_5xx.html"
  source = var.error_5xx_html_path
}