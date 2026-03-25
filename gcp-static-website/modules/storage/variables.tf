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