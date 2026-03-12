variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

# variable "allowed_cidr_blocks" {
#   type = list(string)
#   default = []
# }

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "multi_az" {
  type    = bool
  default = true
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "kms_key_id" {
  type    = string
  default = null
}

variable "allowed_security_group_ids" {
  type    = list(string)
  default = []
}