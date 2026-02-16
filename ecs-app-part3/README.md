## Python "Hello World" app on ECS Fargate
The project consists of Terraform configuration to implement a scalable Python application using AWS ECS Fargate service.

## Project Structure
The project is organized in modules, to make the code reusable:
* modules/vpc - creates a custom network (VPC, 2 public subnets, 2 private subnets, IGW, NAT Gateway).
* modules/ecr-repository - configures the repo for Docker images.
* modules/ecs-cluster - defines ECS cluster with Fargate.
* modules/ecs-task-definition - defines Task with CPU=256, Memory=512 and CloudWatch logging.
* modules/alb - creates an Application Load Balancer with port 80 Listener and Target Group forwarding to 8080.
* modules/ecs-service - manages ECS service in private subnets (with autoscaling, 1-2 tasks).

## State Management
The project utilizes Terraform Cloud for centralized state storage and state locking.

## Run Instructions
```bash
1. terraform init
2. terraform plan
3. terraform apply
4. terraform destroy
```