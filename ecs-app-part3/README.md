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

## Pipeline CI/CD (using GitHub Actions)
Workflow consits of 3 main stages, starting on push to `main`:
1. Init & Validate: Terraform init, formatting check and tflint code analysis.
2. Plan: Generating the plan of changes to infrastructure.
3. Apply & Deploy: Requires manual confirmation.

## Run Instructions
Due to the fact that IAM roles for GitHub Actions are managed by the same Terraform code, bootstrapping from local machine is required to "allow" access for GitHub.

**Run the following command before first pipeline run:**

```bash
terraform apply \
  -target=aws_iam_openid_connect_provider.github \
  -target=aws_iam_role.github_tf_plan \
  -target=aws_iam_role_policy_attachment.plan_read_only \
  -target=aws_iam_role.github_tf_apply \
  -target=aws_iam_role_policy_attachment.apply_admin
```

## Destroy Instructions
In order to destroy all resources, use "Terraform Destroy ECS-App-Part3" workflow in Actions tab.