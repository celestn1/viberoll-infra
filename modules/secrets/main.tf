# ------------------------------
# viberoll-infra/modules/secrets/main.tf
# ------------------------------
resource "aws_secretsmanager_secret" "secrets" {
  for_each = var.secrets_map
  name     = "${var.project_name}-${each.key}"

  tags = {
    Project = var.project_name
  }
}

resource "aws_secretsmanager_secret_version" "secrets_version" {
  for_each      = var.secrets_map
  secret_id     = aws_secretsmanager_secret.secrets[each.key].id
  secret_string = each.value
}

variable "secrets_map" {
  type        = map(string)
  description = "Map of secret key-value pairs to be stored in AWS Secrets Manager"
}

variable "project_name" {
  type        = string
  description = "Project name used as a prefix for secrets"
}
