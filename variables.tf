# ------------------------------
# viberoll-infra/variables.tf
# ------------------------------

variable "aws_region" {
  description = "AWS region to deploy all resources"
  type        = string
  default     = "eu-west-2"
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
}

variable "db_username" {
  description = "Username for the PostgreSQL database"
  type        = string
}

variable "db_password" {
  description = "Password for the PostgreSQL database"
  type        = string
  sensitive   = true
}

variable "secrets_map" {
  description = "Map of secrets to store in AWS Secrets Manager"
  type        = map(string)
  default     = {}
}
