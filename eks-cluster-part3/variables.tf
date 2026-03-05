variable "region" {
  description = "AWS region where the EKS cluster will be deployed."
  type        = string
}

variable "vpc_id" {
  description = "ID of the existing VPC for the EKS cluster."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs in the VPC for EKS resources."
  type        = list(string)
}
