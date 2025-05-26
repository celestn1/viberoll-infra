# ------------------------------
# viberoll-infra/modules/secrets/main.tf
# ------------------------------

resource "aws_secretsmanager_secret" "secrets" {
  for_each = {
    for key, value in var.secrets_map :
    "${var.project_name}-${key}" => value
  }

  name = each.key

  tags = merge(var.tags, {
    Expire     = "true"
    Destroy_By = "2025-05-25T18:00:00Z"
  })

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [tags_all]
  }
}

resource "aws_secretsmanager_secret_version" "secrets_version" {
  for_each = {
    for key, value in var.secrets_map :
    "${var.project_name}-${key}" => value if try(trim(value), "") != ""
  }

  secret_id     = aws_secretsmanager_secret.secrets[each.key].id
  secret_string = each.value
}

resource "null_resource" "verify_aws_current_labels" {
  provisioner "local-exec" {
    command = join("\n", [
      "echo 🔍 Verifying AWSCURRENT labels...",
      for key, value in var.secrets_map : <<EOT
if [[ "${try(trim(value), "")}" != "" ]]; then
  echo "🔎 ${var.project_name}-${key}"
  aws secretsmanager describe-secret \
    --secret-id ${var.project_name}-${key} \
    --region ${var.aws_region} \
    --query 'VersionIdsToStages' \
    --output text | grep AWSCURRENT || echo "❌ Missing AWSCURRENT for ${var.project_name}-${key}"
fi
EOT
    ])
  }

  depends_on = [aws_secretsmanager_secret_version.secrets_version]
}
