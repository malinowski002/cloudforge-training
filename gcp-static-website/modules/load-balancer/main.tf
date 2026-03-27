resource "google_compute_global_address" "default" {
  name = "static-website-global-address"
}

resource "google_compute_global_forwarding_rule" "default" {
  name                  = "static-website-forwarding-rule"
  target                = google_compute_target_http_proxy.default.id
  port_range            = "80"
  ip_address            = google_compute_global_address.default.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "static-website-https-forwarding-rule"
  target                = google_compute_target_https_proxy.default.id
  port_range            = "443"
  ip_address            = google_compute_global_address.default.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
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

  default_custom_error_response_policy {
    error_service = google_compute_backend_bucket.cdn_backend.id

    error_response_rule {
      match_response_codes   = ["404"]
      path                   = "/error_404.html"
      override_response_code = 404
    }

    error_response_rule {
      match_response_codes   = ["500", "502", "503", "504"]
      path                   = "/error_5xx.html"
      override_response_code = 500
    }
  }
}

resource "google_compute_url_map" "https" {
  name = "static-website-https-url-map"
  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

resource "google_compute_backend_bucket" "cdn_backend" {
  name        = "static-website-backend-bucket"
  bucket_name = var.backend_bucket_name
  enable_cdn  = true

  custom_response_headers = ["content-type:text/html"]
}

resource "google_compute_ssl_certificate" "default" {
  name        = "static-website-ssl-certificate"
  private_key = var.ssl_private_key
  certificate = var.ssl_certificate
}