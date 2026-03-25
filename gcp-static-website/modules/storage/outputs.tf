output "bucket_name" {
  value = google_storage_bucket.website.name
}

output "bucket_url" {
  value = google_storage_bucket.website.url
}