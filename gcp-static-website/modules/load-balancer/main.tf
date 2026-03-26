resource "google_compute_global_address" "default" {
  name = "static-website-global-address"
}

resource "google_compute_global_forwarding_rule" "default" {
  name                  = "static-website-forwarding-rule"
  target                = google_compute_target_http_proxy.default.id
  port_range            = "80"
  ip_address            = google_compute_global_address.default.address
  load_balancing_scheme = "EXTERNAL"
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "static-website-https-forwarding-rule"
  target                = google_compute_target_https_proxy.default.id
  port_range            = "443"
  ip_address            = google_compute_global_address.default.address
  load_balancing_scheme = "EXTERNAL"
}

resource "google_compute_target_http_proxy" "default" {
  name    = "static-website-http-proxy"
  url_map = google_compute_url_map.https.id
}

resource "google_compute_target_https_proxy" "default" {
  name             = "static-website-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_ssl_certificate.default.id]
}

resource "google_compute_url_map" "default" {
  name            = "static-website-url-map"
  default_service = google_compute_backend_bucket.cdn_backend.id
}

resource "google_compute_url_map" "https" {
  name           = "static-website-https-url-map"
  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

resource "google_compute_backend_bucket" "cdn_backend" {
  name        = "static-website-backend-bucket"
  bucket_name = var.backend_bucket_name
  enable_cdn  = true
}

resource "google_compute_ssl_certificate" "default" {
  name        = "static-website-ssl-certificate"
  private_key = file(var.ssl_certificate_private_key_path)
  certificate = file(var.ssl_certificate_path)
}