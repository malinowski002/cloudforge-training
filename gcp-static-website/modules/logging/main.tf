resource "google_storage_bucket" "logs" {
    name = var.bucket_name
    location = var.region
    uniform_bucket_level_access = true

    lifecycle_rule {
      action {
        type = "Delete"
      }
      condition {
        age = 30
      }
    }
}

resource "google_logging_project_sink" "lb_logs" {
    name = "static-website-lb-logs"
    destination = "storage.googleapis.com/${google_storage_bucket.logs.name}"
    filter = "resource.type=\"http_load_balancer\""
    unique_writer_identity = true
}

resource "google_storage_bucket_iam_member" "logs_writer" {
    bucket = google_storage_bucket.logs.name
    role = "roles/storage.objectCreator"
    member = google_logging_project_sink.lb_logs.writer_identity
}