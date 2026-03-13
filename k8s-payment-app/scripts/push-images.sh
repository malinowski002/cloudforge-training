#!/usr/bin/env bash
set -euo pipefail

REGION="eu-central-1"
ECR_JSON="$(terraform -chdir=infrastructure output -json ecr_repository_urls)"
PAYMENT_API_REPO="$(echo "$ECR_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin)["payment-api"])')"
PAYMENT_WORKER_REPO="$(echo "$ECR_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin)["payment-worker"])')"
REGISTRY="${PAYMENT_API_REPO%%/*}"

aws ecr get-login-password --region "$REGION" \
    | docker login --username AWS --password-stdin "$REGISTRY"

docker build -t payment-api ./payment-api
docker build -t payment-worker ./payment-worker

docker tag payment-api:latest "$PAYMENT_API_REPO:latest"
docker tag payment-worker:latest "$PAYMENT_WORKER_REPO:latest"

docker push "$PAYMENT_API_REPO:latest"
docker push "$PAYMENT_WORKER_REPO:latest"