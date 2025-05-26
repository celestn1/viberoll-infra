# ------------------------------
# viberoll-infra/modules/alb/variables.tf
# ------------------------------

variable "create_alb" {
  type        = bool
  description = "Whether to create a new ALB or assume it already exists"
  default     = true
}

variable "alb_arn" {
  type        = string
  description = "ARN of existing ALB to use if not creating a new one"
  default     = ""
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "project_name" {
  type = string
}
