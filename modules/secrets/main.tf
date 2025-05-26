# ------------------------------
# viberoll-infra/modules/secrets/main.tf
# ------------------------------

resource "aws_secretsmanager_secret" "secrets" {
  # filter out any empty values, using static keys
  for_each = {
    for key, value in var.secrets_map :
    key => value
    if length(trim(value, " ")) > 0
  }

  # construct the AWS secret name at apply-time
  name        = "${var.project_name}-${each.key}"
  description = "Managed secret ${each.key} for ${var.environment}"

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [tags_all]
  }
}

resource "aws_secretsmanager_secret_version" "secrets_version" {
  # only iterate over the secrets you actually created above
  for_each       = aws_secretsmanager_secret.secrets
  secret_id      = each.value.id
  secret_string  = each.value
  version_stages = ["AWSCURRENT"]
}
