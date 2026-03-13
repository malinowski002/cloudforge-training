variable "repositories" {
  description = "List of ECR repository names"
  type        = list(string)
}

variable "image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}

variable "scan_on_push" {
  type    = bool
  default = true
}

variable "encryption_type" {
  type    = string
  default = "AES256"
}