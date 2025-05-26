#-------------------------
# viberoll-infra/modules/secrets/outputs.tf
#-------------------------

output "secret_arns" {
  description = "Map of secret keys to their ARNs"
  value = {
    for key, secret in aws_secretsmanager_secret.secrets :
    key => secret.arn
  }
}
