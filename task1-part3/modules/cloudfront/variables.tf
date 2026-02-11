variable "s3_bucket_id" {
    description = "ID of origin S3 bucket"
    type = string
}

variable "s3_bucket_origin_domain_name" {
    description = "S3 bucket domain name"
    type = string
}

variable "logs_bucket_domain_name" {
    description = "S3 bucket domain name for logs"
    type = string
}

variable "web_acl_id" {
    description = "WAF ARN"
    type = string
    default = null
}