variable "name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "app"
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_dns_support" {
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  default     = true
}

variable "tags" {
  description = "Extra tags to apply to the VPC and subnets"
  type        = map(string)
  default     = {}
}

variable "public_subnets" {
  description = "List of public subnets to create"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = []
}

variable "private_subnets" {
  description = "List of private subnets to create"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = []
}
