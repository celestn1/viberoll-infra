#!/bin/bash
set -euo pipefail

PROJECT_NAME="viberoll"
REGION="eu-west-2"

echo "🔍 Fetching secrets from Secrets Manager..."

SECRETS=$(aws secretsmanager list-secrets \
  --region "$REGION" \
  --query "SecretList[?starts_with(Name, \`${PROJECT_NAME}-\`)].Name" \
  --output text)

if [[ -z "$SECRETS" ]]; then
  echo "❌ No secrets found with prefix '${PROJECT_NAME}-'"
  exit 0
fi

echo -e "\nFound secrets:\n$SECRETS\n"

for SECRET_NAME in $SECRETS; do
  KEY_NAME="${SECRET_NAME#${PROJECT_NAME}-}"
  echo "➡️ Importing: $SECRET_NAME as key [$KEY_NAME]"

  terraform import "module.secrets.aws_secretsmanager_secret.secrets[\"${KEY_NAME}\"]" "$SECRET_NAME" || {
    echo "⚠️ Failed to import $SECRET_NAME — skipping"
    continue
  }

  echo "✅ Successfully imported $KEY_NAME"
done

echo -e "\n✅ All secrets imported (or skipped if already present)."
