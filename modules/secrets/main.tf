# ------------------------------
# viberoll-infra/modules/secrets/main.tf
# ------------------------------

variable "secrets_map" {
  type        = map(string)
  description = "Map of secret key-value pairs to be stored in AWS Secrets Manager"
}

variable "project_name" {
  type        = string
  description = "Project name used as a prefix for secrets"
}

resource "aws_secretsmanager_secret" "secrets" {
  for_each = var.secrets_map

  name = "${var.project_name}-${each.key}"

  tags = {
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
    Destroy_By  = "2025-05-25T18:00:00Z"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name] # Prevent recreation error if it already exists
  }
}

resource "aws_secretsmanager_secret_version" "secrets_version" {
  for_each = {
    for key, value in var.secrets_map :
    key => value if try(trim(value), "") != ""
  }

  secret_id     = aws_secretsmanager_secret.secrets[each.key].id
  secret_string = each.value
}

output "secret_arns" {
  description = "Map of secret keys to their ARNs"
  value = {
    for key, secret in aws_secretsmanager_secret.secrets :
    key => secret.arn
  }
}
