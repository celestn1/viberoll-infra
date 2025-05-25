#!/bin/bash
set -euo pipefail

PROJECT_NAME="viberoll"
REGION="eu-west-2"

echo "🔍 Fetching secrets from AWS Secrets Manager in region $REGION..."

SECRETS=$(aws secretsmanager list-secrets \
  --region "$REGION" \
  --query "SecretList[?starts_with(Name, \`${PROJECT_NAME}-\`)].Name" \
  --output text || true)

if [[ -z "${SECRETS:-}" ]]; then
  echo "❌ No secrets found with prefix '${PROJECT_NAME}-'"
  exit 0
fi

echo -e "\n🔑 Found secrets:\n$SECRETS\n"

for SECRET_NAME in $SECRETS; do
  KEY_NAME="${SECRET_NAME#${PROJECT_NAME}-}"
  echo "➡️ Importing: $SECRET_NAME as key [$KEY_NAME]..."

  timeout 30 terraform import "module.secrets.aws_secretsmanager_secret.secrets[\"${KEY_NAME}\"]" "$SECRET_NAME" \
    && echo "✅ Imported: $KEY_NAME" \
    || echo "⚠️ Failed or already imported: $KEY_NAME"
done

echo -e "\n🎉 Finished attempting to import all secrets.\n"
