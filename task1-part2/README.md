## Project Structure

Infrastructure is created with independent modules inside the `modules` directory:
* S3 - hosting index.html file, blocking all public access.
* CloudFront - allows HTTPS access, utilizes OAC guaranteeing access to S3 only with CloudFront.
* WAF - adds security against common/known threats (AWS Managed Rules).

## Terraform State

In order to prevent concurrent changes and keep TF state in a centralized place, tfstate is stored using HCP Terraform. It automatically blocks the possibility of modifying the infrastructure by more than 1 person simultaneously and makes sure all engineers have the same state.

## Run instructions

All commands below should be executed in `task1-part2` directory:

```bash
1. terraform init
2. terraform plan
3. terraform apply
4. terraform destroy
```