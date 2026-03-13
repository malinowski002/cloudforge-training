#!/usr/bin/env bash
set -euo pipefail

REGION="eu-central-1"
TAG="${TAG:-latest}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
PAYMENT_API_REPO="${REGISTRY}/payment-api"
PAYMENT_WORKER_REPO="${REGISTRY}/payment-worker"

aws ecr get-login-password --region "$REGION" \
    | docker login --username AWS --password-stdin "$REGISTRY"

docker buildx create --use --name multi >/dev/null 2>&1 || true

docker buildx build --platform linux/amd64 -t "$PAYMENT_API_REPO:$TAG" --push ./payment-api
docker buildx build --platform linux/amd64 -t "$PAYMENT_WORKER_REPO:$TAG" --push ./payment-worker
