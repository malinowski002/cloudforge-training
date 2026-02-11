variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "eu-north-1"
}

variable "bucket_name" {
  description = "Name for the S3 bucket"
  type        = string
}