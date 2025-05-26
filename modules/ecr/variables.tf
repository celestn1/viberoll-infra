#----------------------------------
# viberoll-infra/modules/ecr/variables.tf
#----------------------------------

variable "repo_name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "project_name" {
  type        = string
  description = "Project name used for tagging"
}

variable "repo_check_enabled" {
  type        = bool
  default     = true
  description = "Enable lookup of existing ECR repository"
}

variable "prevent_destroy" {
  type        = bool
  default     = false
  description = "Prevent accidental repo deletion (set to false for destroy)"
}
