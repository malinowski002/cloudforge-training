#!/usr/bin/env bash
set -euo pipefail

CLUSTER="${CLUSTER:-k8s-payment-eks}"
REGION="${REGION:-eu-central-1}"
POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"

for cmd in aws eksctl kubectl helm curl; do
    command -v "$cmd" >/dev/null || { echo "Missing $cmd"; exit 1; }
done

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}"

# ensure OIDC provider exists
eksctl utils associate-iam-oidc-provider --cluster "$CLUSTER" --region "$REGION" --approve

# create IAM policy if it doesn't exist
if ! aws iam get-policy --policy-arn "$POLICY_ARN" >/dev/null 2>&1; then
    curl -fsSL -o /tmp/iam_policy.json \
        https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

    aws iam create-policy \
        --policy-name "$POLICY_NAME" \
        --policy-document file:///tmp/iam_policy.json
fi

# create IRSA service account
eksctl create iamserviceaccount \
    --cluster "$CLUSTER" \
    --region "$REGION" \
    --namespace kube-system \
    --name aws-load-balancer-controller \
    --attach-policy-arn "$POLICY_ARN" \
    --override-existing-serviceaccounts \
    --approve

# install / upgrade controller
helm repo add eks https://aws.github.io/eks-charts >/dev/null 2>&1 || true
helm repo update >/dev/null

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName="$CLUSTER" \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller

kubectl -n kube-system rollout status deploy/aws-load-balancer-controller
