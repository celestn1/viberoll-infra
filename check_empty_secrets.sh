#!/bin/bash

set -euo pipefail

PROJECT_NAME="viberoll"
AWS_REGION="eu-west-2"
PREFIX="${PROJECT_NAME}-"

echo "🔍 Checking for empty secrets for prefix: $PREFIX"

aws secretsmanager list-secrets \
  --region "$AWS_REGION" \
  --query "SecretList[?starts_with(Name, '$PREFIX')].Name" \
  --output text | tr '\t' '\n' | while read -r secret_name; do
    echo "🔎 Inspecting $secret_name..."

    value=$(aws secretsmanager get-secret-value \
      --secret-id "$secret_name" \
      --region "$AWS_REGION" \
      --query SecretString \
      --output text 2>/dev/null || echo "MISSING")

    if [[ "$value" == "MISSING" ]]; then
      echo "⚠️  $secret_name not found or has no value"
    elif [[ -z "$value" ]]; then
      echo "🚨 $secret_name is EMPTY ❌"
    else
      echo "✅ $secret_name is populated"
    fi
done

