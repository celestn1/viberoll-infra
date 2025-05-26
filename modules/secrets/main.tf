# ------------------------------
# viberoll-infra/modules/secrets/main.tf
# ------------------------------

resource "aws_secretsmanager_secret" "secrets" {
  for_each = var.secrets_map

  name        = "${var.project_name}-${each.key}"
  description = "Managed secret ${each.key} for ${var.environment}"

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [tags_all]
  }
}

resource "aws_secretsmanager_secret_version" "secrets_version" {
  for_each = aws_secretsmanager_secret.secrets

  secret_id = each.value.id

  # fallback to a default string if the value is not valid
  secret_string = try(
    length(trim(var.secrets_map[each.key], " ")) > 0 ? var.secrets_map[each.key] : "REDACTED",
    "REDACTED"
  )

  version_stages = ["AWSCURRENT"]
}
