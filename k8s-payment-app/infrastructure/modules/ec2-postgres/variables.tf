variable "vpc_id" {
    type = string
}

variable "subnet_id" {
    type = string
    description = "Private subnet to place the instance in"
}

variable "eks_node_security_group_id" {
    type = string
    description = "EKS node SG allowing to reach PostgreSQL"
}

variable "db_password" {
    type = string
    sensitive = true
}

variable "instance_type" {
    type = string
    default = "t3.micro"
}