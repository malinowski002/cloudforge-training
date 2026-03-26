variable "bucket_name" {
  description = "The name of the bucket"
  type        = string
}

variable "region" {
  description = "Region to put the bucket in"
  type        = string
}

variable "index_html_path" {
  description = "Path to the index.html file"
  type        = string
}

variable "error_404_html_path" {
  description = "Path to the custom 404 error page"
  type        = string
  default     = "error_404.html"
}

variable "error_5xx_html_path" {
  description = "Path to the custom 5xx error page"
  type        = string
  default     = "error_5xx.html"

}