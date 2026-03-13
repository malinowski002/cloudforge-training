#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="payments-ns"
CHART_DIR="helm/payments"
REGION="eu-central-1"

RDS_ENDPOINT="$(terraform -chdir=infrastructure output -raw rds_endpoint)"
RDS_SECRET_ARN="$(terraform -chdir=infrastructure output -raw rds_master_secret_arn)"

ECR_JSON="$(terraform -chdir=infrastructure output -json ecr_repository_urls)"
PAYMENT_API_REPO="$(echo "$ECR_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin)["payment-api"])')"
PAYMENT_WORKER_REPO="$(echo "$ECR_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin)["payment-worker"])')"
TAG="latest"

DB_PASSWORD="$(
    aws secretsmanager get-secret-value \
      --secret-id "$RDS_SECRET_ARN" \
      --region "$REGION" \
      --query SecretString \
      --output text | python3 -c 'import json,sys; print(json.loads(sys.stdin.read())["password"])'
    )"

helm upgrade --install payments "$CHART_DIR" \
    -n "$NAMESPACE" --create-namespace \
    --set-string db.endpoint="$RDS_ENDPOINT" \
    --set-string db.password="$DB_PASSWORD" \
    --set-string db.user="payments" \
    --set-string paymentApi.image.repository="$PAYMENT_API_REPO" \
    --set-string paymentWorker.image.repository="$PAYMENT_WORKER_REPO" \
    --set-string paymentApi.image.tag="$TAG" \
    --set-string paymentWorker.image.tag="$TAG"