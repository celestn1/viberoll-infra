# ------------------------------
# viberoll-infra/variables.tf
# ------------------------------

variable "aws_region" {
  description = "AWS region to deploy all resources"
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, production)"
  type        = string
}

variable "project_name" {
  description = "Project or environment name used for tagging and resource naming"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "container_image" {
  description = "Full URI of the Docker image (e.g., from ECR)"
  type        = string
}

variable "db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "viberoll"
}

variable "db_username" {
  description = "Username for the PostgreSQL database"
  type        = string
  default     = "viberoll_admin"
}

variable "db_password" {
  description = "Password for the PostgreSQL database"
  type        = string
  sensitive   = true
}

# ------------------------------
# Secure Secrets for Runtime Injection
# ------------------------------

variable "jwt_secret" {
  description = "JWT access token secret"
  type        = string
  sensitive   = true
}

variable "jwt_refresh_secret" {
  description = "JWT refresh token secret"
  type        = string
  sensitive   = true
}

variable "wallet_private_key" {
  description = "Private key for blockchain wallet"
  type        = string
  sensitive   = true
  default     = ""
}

variable "nft_contract_address" {
  description = "NFT contract address for the application"
  type        = string
  default     = ""
}

variable "openai_api_key" {
  description = "OpenAI API key used for content generation"
  type        = string
  sensitive   = true
  default     = ""
}

variable "admin_email" {
  description = "Seed admin user email"
  type        = string
  default     = "admin@viberoll.dev"
}

variable "admin_password" {
  description = "Seed admin user password"
  type        = string
  sensitive   = true
}

variable "admin_username" {
  description = "Seed admin user username"
  type        = string
  default     = "viberoll_admin"
}

# ------------------------------
# Optional Dynamic Secrets Map (preferred via GitHub Actions)
# ------------------------------

variable "secrets_map" {
  description = "Map of runtime secrets injected dynamically from CI"
  type        = map(string)
  default     = {}
}

variable "repo_check_enabled" {
  type        = bool
  default     = true
  description = "Enable check for existing ECR repo before creating"
}
