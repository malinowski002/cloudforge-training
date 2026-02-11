## Project Structure

Infrastructure is created with independent modules inside the `modules` directory:
* S3 - hosting index.html file, blocking all public access.
* CloudFront - allows HTTPS access, utilizes OAC guaranteeing access to S3 only with CloudFront.
* WAF - adds security against common/known threats (AWS Managed Rules).

## Error Pages

The website serves custom error pages from the S3 bucket:
* 4xx Errors - to view, try to access a non-existent path (`https://dxxxxxxxxxxxxx.cloudfront.net/test`).
* 5xx Errors - show an error page in case of backend/origin failure.

## Access Logs

Logs are stored in a dedicated S3 bucket `kacper-task1-part3-bucket-logs`.
* To access, go to the S3 console, open the logs bucket and download the `.gz` files.
* Logs are automatically deleted after 30 days using Lifecycle Rules.

## Monitoring Dashboard
* To access, go to Cloudwatch > Dashboards in the `us-east-1` region.
* The dashboard is called `Dashboard-kacper-task1-part3-bucket` and it displays request counts, error rates and WAF blocked requests.

## CI/CD Pipeline
The project uses Github Actions:
1. Init & Validate - runs on every `push`, checks code formatting and syntax using `terraform fmt` and `terraform validate`.
2. Plan - triggeres automatically on `push` to the main branch.
3. Apply - requires manual approval.
4. Destroy - can be triggered via HCP Terraform.