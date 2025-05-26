#-----------------------
# viberoll-infra/modules/secrets/variables.tf
#-----------------------

variable "secrets_map" {
  type        = map(string)
  description = "Map of secret key-value pairs to be stored in AWS Secrets Manager"
}

variable "project_name" {
  type        = string
  description = "Project name used as a prefix for secrets"
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all secrets"
  default     = {}
}
