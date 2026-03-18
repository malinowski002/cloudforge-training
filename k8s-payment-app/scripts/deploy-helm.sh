#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="payments-ns"
CHART_DIR="helm/payments"
REGION="eu-central-1"

VM_IP="$(terraform -chdir=infrastructure output -raw ec2_postgres_private_ip)"
DB_ENDPOINT="${VM_IP}:5432"
DB_PASSWORD="payments"

ECR_JSON="$(terraform -chdir=infrastructure output -json ecr_repository_urls)"
PAYMENT_API_REPO="$(echo "$ECR_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin)["payment-api"])')"
PAYMENT_WORKER_REPO="$(echo "$ECR_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin)["payment-worker"])')"
TAG="latest"

helm upgrade --install payments "$CHART_DIR" \
    -n "$NAMESPACE" --create-namespace \
    --set-string db.endpoint="$DB_ENDPOINT" \
    --set-string db.password="$DB_PASSWORD" \
    --set-string db.user="payments" \
    --set-string paymentApi.image.repository="$PAYMENT_API_REPO" \
    --set-string paymentWorker.image.repository="$PAYMENT_WORKER_REPO" \
    --set-string paymentApi.image.tag="$TAG" \
    --set-string paymentWorker.image.tag="$TAG"