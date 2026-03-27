variable "bucket_name" {
  description = "The name of the bucket to store logs."
  type        = string
}

variable "region" {
  description = "The region where the logging bucket will be created."
  type        = string
}