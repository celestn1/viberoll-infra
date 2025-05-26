#!/bin/bash

set -euo pipefail

# ────────────────────────────────────────────────────────────────
# CONFIGURATION
# ────────────────────────────────────────────────────────────────

PROJECT_NAME="viberoll"
AWS_REGION="eu-west-2"
SECRETS_PREFIX="${PROJECT_NAME}-"

echo "🧨 Starting full infrastructure teardown for project: $PROJECT_NAME"

# ────────────────────────────────────────────────────────────────
# STEP 1: Terraform destroy
# ────────────────────────────────────────────────────────────────

echo "🧹 Running terraform destroy..."
terraform init -upgrade
terraform destroy -auto-approve

# ────────────────────────────────────────────────────────────────
# STEP 2: Force-delete secrets
# ────────────────────────────────────────────────────────────────

echo "🔐 Finding and force-deleting AWS Secrets for: $SECRETS_PREFIX"

aws secretsmanager list-secrets \
  --region "$AWS_REGION" \
  --query "SecretList[?starts_with(Name, '$SECRETS_PREFIX')].Name" \
  --output text | tr '\t' '\n' | while read -r secret_name; do
    echo "🚨 Deleting secret: $secret_name"
    aws secretsmanager delete-secret \
      --secret-id "$secret_name" \
      --region "$AWS_REGION" \
      --force-delete-without-recovery || echo "⚠️ Skipped $secret_name"
done

# ────────────────────────────────────────────────────────────────
# STEP 3: Cleanup local .terraform directory (optional)
# ────────────────────────────────────────────────────────────────

echo "🧼 Cleaning local Terraform cache..."
rm -rf .terraform terraform.tfstate terraform.tfstate.backup tfplan || true

echo "✅ Teardown complete."

