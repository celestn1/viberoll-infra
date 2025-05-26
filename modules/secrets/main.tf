# ------------------------------
# viberoll-infra/modules/secrets/main.tf
# ------------------------------

resource "aws_secretsmanager_secret" "secrets" {
  # iterate over all entries in var.secrets_map (all are non-empty by var validation)
  for_each = var.secrets_map

  # construct the actual AWS Secret name
  name        = "${var.project_name}-${each.key}"
  description = "Managed secret ${each.key} for ${var.environment}"

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [tags_all]
  }
}

resource "aws_secretsmanager_secret_version" "secrets_version" {
  # now iterate exactly over the secrets you created above
  for_each       = aws_secretsmanager_secret.secrets
  secret_id      = each.value.id
  secret_string  = each.value
  version_stages = ["AWSCURRENT"]
}