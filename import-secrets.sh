#!/bin/bash

# Make sure this script exits on any error
set -euo pipefail

# Define your project name (should match your Terraform var.project_name)
PROJECT_NAME="viberoll"

# Define the AWS region
REGION="eu-west-2"

# Get list of matching secrets
SECRETS=$(aws secretsmanager list-secrets \
  --region "$REGION" \
  --query "SecretList[?starts_with(Name, \`${PROJECT_NAME}-\`)].Name" \
  --output text)

# Exit if no secrets found
if [[ -z "$SECRETS" ]]; then
  echo "No secrets found starting with '${PROJECT_NAME}-' in region ${REGION}"
  exit 0
fi

echo "Found secrets:"
echo "$SECRETS"
echo

# Loop and import each secret
for SECRET_NAME in $SECRETS; do
  # Extract just the key name (e.g., JWT_SECRET from viberoll-JWT_SECRET)
  KEY_NAME="${SECRET_NAME#${PROJECT_NAME}-}"

  echo "Importing: $SECRET_NAME (key = $KEY_NAME)"
  
  terraform import "module.secrets.aws_secretsmanager_secret.secrets[\"${KEY_NAME}\"]" "$SECRET_NAME"
done

echo
echo "✅ All secrets imported successfully into Terraform state."
