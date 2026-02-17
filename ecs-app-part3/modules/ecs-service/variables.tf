variable "name" {
  description = "The name of the ECS service to deploy."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the ECS service security group will be created."
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB allowed to reach the ECS tasks."
  type        = string
}

variable "cluster" {
  description = "The ECS cluster to deploy the service in."
  type        = string
}

variable "task_definition" {
  description = "The task definition to use for the service."
  type        = string
}

variable "desired_count" {
  description = "The number of desired tasks to run."
  type        = number
  default     = 1
}

variable "enable_autoscaling" {
  description = "Whether to enable ECS service autoscaling."
  type        = bool
  default     = true
}

variable "min_count" {
  description = "Minimum number of tasks for ECS service autoscaling."
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum number of tasks for ECS service autoscaling."
  type        = number
  default     = 2
}

variable "launch_type" {
  description = "The launch type on which to run your service."
  type        = string
  default     = "FARGATE"
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "subnets" {
  description = "A list of subnet IDs to associate with the service."
  type        = list(string)
}

variable "security_groups" {
  description = "Additional security group IDs to associate with the service."
  type        = list(string)
  default     = []
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to ECS tasks."
  type        = bool
  default     = false
}

variable "target_group_arn" {
  description = "ARN of the ALB target group for the service."
  type        = string
}

variable "container_name" {
  description = "The name of the container to associate with the load balancer."
  type        = string
}

variable "container_port" {
  description = "The port on the container to associate with the load balancer."
  type        = number
}

variable "cpu_high_threshold" {
  description = "CPU utilization percentage to scale up"
  type        = number
  default     = 50
}

variable "cpu_low_threshold" {
  description = "CPU utilization percentage to scale down"
  type        = number
  default     = 25
}

variable "scale_in_minutes" {
  description = "Minutes below threshold before scaling in"
  type        = number
  default     = 5
}