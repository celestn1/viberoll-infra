# ------------------------------
# viberoll-infra/modules/ecs/variables.tf
# ------------------------------

variable "secret_arns" {
  type        = map(string)
  description = "Map of secret names to their ARNs from AWS Secrets Manager for injection into ECS tasks"
}

variable "cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
}

variable "container_image" {
  type        = string
  description = "Full image URI for the ECS container (e.g., from ECR)"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs for ECS service networking"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs to attach to the ECS service"
}

variable "target_group_arn" {
  type        = string
  description = "Target Group ARN for the ECS service to register with"
}

variable "alb_listener_arn" {
  type        = string
  description = "ALB listener ARN required for the ECS service dependency"
}

variable "project_name" {
  type        = string
  description = "Unique identifier used for naming ECS resources"
}

variable "aws_region" {
  type        = string
  default     = "eu-west-2"
  description = "AWS region where resources will be deployed"
}
