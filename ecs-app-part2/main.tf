data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_a = data.aws_availability_zones.available.names[0]
  az_b = data.aws_availability_zones.available.names[1]
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  name       = "app"
  cidr_block = "10.0.0.0/16"

  public_subnets = [
    { name = "public-subnet-a", cidr = "10.0.0.0/24", az = local.az_a },
    { name = "public-subnet-b", cidr = "10.0.2.0/24", az = local.az_b },
  ]

  private_subnets = [
    { name = "private-subnet-a", cidr = "10.0.1.0/24", az = local.az_a },
    { name = "private-subnet-b", cidr = "10.0.3.0/24", az = local.az_b },
  ]
}

module "ecr_repository" {
  source = "./modules/ecr-repository"

  name = "app"
}

module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  name = "app"
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "app-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

module "ecs_task_definition" {
  source = "./modules/ecs-task-definition"

  family             = "app"
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = [
    {
      name      = "app"
      image     = "${module.ecr_repository.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
    }
  ]
}

module "alb" {
  source = "./modules/alb"

  name    = "app"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnet_ids
}
