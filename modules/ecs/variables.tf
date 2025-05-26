# ------------------------------
# viberoll-infra/modules/ecs/variables.tf
# ------------------------------
variable "cluster_name" {
  type = string
}

variable "container_image" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "alb_listener_arn" {
  type = string
}

variable "project_name" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}
