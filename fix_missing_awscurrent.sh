#!/bin/bash
set -euo pipefail

REGION="eu-west-2"
PREFIX="viberoll-"

echo "🔍 Scanning Secrets Manager for missing 'AWSCURRENT' labels..."
SECRET_NAMES=$(aws secretsmanager list-secrets --region "$REGION" \
  --query "SecretList[?starts_with(Name, \`${PREFIX}\`)].Name" \
  --output text)

for SECRET_NAME in $SECRET_NAMES; do
  echo "🔎 Checking $SECRET_NAME..."

  # Get version info
  VERSION_IDS_JSON=$(aws secretsmanager describe-secret \
    --secret-id "$SECRET_NAME" \
    --region "$REGION" \
    --query "VersionIdsToStages" \
    --output json)

  if [[ "$VERSION_IDS_JSON" == "null" ]]; then
    echo "⚠️  $SECRET_NAME has no versions (empty secret) — skipping"
    continue
  fi

  CURRENT_FOUND=$(echo "$VERSION_IDS_JSON" | jq -r '.[] | select(.[] == "AWSCURRENT")' | wc -l)

  if [[ "$CURRENT_FOUND" -eq 0 ]]; then
    echo "⚠️  $SECRET_NAME is missing 'AWSCURRENT' — fixing..."

    # Get the most recent version ID
    LATEST_VERSION_ID=$(echo "$VERSION_IDS_JSON" | jq -r 'keys[0]')
    SECRET_STRING=$(aws secretsmanager get-secret-value \
      --secret-id "$SECRET_NAME" \
      --version-id "$LATEST_VERSION_ID" \
      --region "$REGION" \
      --query "SecretString" \
      --output text)

    # Re-put the secret value so it gets AWSCURRENT
    aws secretsmanager put-secret-value \
      --secret-id "$SECRET_NAME" \
      --secret-string "$SECRET_STRING" \
      --region "$REGION"

    echo "✅ Fixed $SECRET_NAME → AWSCURRENT set"
  else
    echo "✅ $SECRET_NAME already has AWSCURRENT"
  fi
done

echo "🎉 All secrets checked and fixed if needed."

