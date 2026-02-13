variable "name" {
  description = "The name of the Application Load Balancer."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the ALB security group will be created."
  type        = string
}

variable "subnets" {
  description = "A list of subnet IDs to attach to the load balancer."
  type        = list(string)
}

variable "security_groups" {
  description = "Additional security group IDs to associate with the load balancer."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
