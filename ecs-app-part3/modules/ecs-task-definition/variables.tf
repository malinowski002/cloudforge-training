variable "family" {
  description = "The name of the task definition family."
  type        = string
}

variable "network_mode" {
  description = "The Docker networking mode to use for the containers in the task."
  type        = string
  default     = "awsvpc"
}

variable "requires_compatibilities" {
  description = "A set of launch types required by the task."
  type        = list(string)
  default     = ["FARGATE"]
}

variable "cpu" {
  description = "The number of CPU units used by the task."
  type        = string
  default     = "256"
}

variable "memory" {
  description = "The amount of memory (in MiB) used by the task."
  type        = string
  default     = "512"
}

variable "execution_role_arn" {
  description = "ARN of the ECS task execution role."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "container_definitions" {
  description = "A list of container definitions in JSON format."
  type        = list(any)
  default     = []
}
