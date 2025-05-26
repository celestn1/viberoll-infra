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
