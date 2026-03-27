resource "google_compute_global_address" "default" {
  name = "static-website-global-address"
}

# ----------------
#  HTTP and HTTPS
# ----------------

# Listen on port 80
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "static-website-forwarding-rule"
  target                = google_compute_target_http_proxy.default.id
  port_range            = "80"
  ip_address            = google_compute_global_address.default.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

# Proxy for HTTP
resource "google_compute_target_http_proxy" "default" {
  name    = "static-website-http-proxy"
  url_map = google_compute_url_map.https.id
}

# URL map for HTTP (redirect to HTTPS)
resource "google_compute_url_map" "https" {
  name = "static-website-https-url-map"
  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

# ---------------
#  HTTPS Section
# ---------------

# Listen on port 443
resource "google_compute_global_forwarding_rule" "https" {
  name                  = "static-website-https-forwarding-rule"
  target                = google_compute_target_https_proxy.default.id
  port_range            = "443"
  ip_address            = google_compute_global_address.default.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

# Proxy for HTTPS
resource "google_compute_target_https_proxy" "default" {
  name             = "static-website-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_ssl_certificate.default.id]
}

# Main URL map
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

# -----------------------
#  Backend & Certificate
# -----------------------

# Backend bucket
resource "google_compute_backend_bucket" "cdn_backend" {
  name        = "static-website-backend-bucket"
  bucket_name = var.backend_bucket_name
  enable_cdn  = true

  custom_response_headers = ["content-type:text/html"]
}

# SSL Certificate
resource "google_compute_ssl_certificate" "default" {
  name_prefix = "static-website-ssl-cert-"
  certificate = file(var.ssl_certificate_path)
  private_key = file(var.ssl_private_key_path)

  lifecycle {
    create_before_destroy = true
  }
}