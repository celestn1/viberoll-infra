# ------------------------------
# viberoll-infra/modules/secrets/main.tf
# ------------------------------

resource "aws_secretsmanager_secret" "secrets" {
  # already filtering out empty values
  for_each = {
    for key, value in var.secrets_map :
    "${var.project_name}-${key}" => value
    if length(trim(value, " ")) > 0
  }

  name        = each.key
  description = "Managed secret ${each.key} for ${var.environment}"

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [tags_all]
  }
}

resource "aws_secretsmanager_secret_version" "secrets_version" {
  # only iterate over actual secrets
  for_each = aws_secretsmanager_secret.secrets

  secret_id     = each.value.id
  secret_string = var.secrets_map[replace(each.key, "${var.project_name}-", "")]
  version_stages = ["AWSCURRENT"]
}