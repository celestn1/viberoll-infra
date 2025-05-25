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

# 🔍 Try fetching existing ECR repo if enabled
data "aws_ecr_repository" "existing" {
  count = var.repo_check_enabled ? 1 : 0
  name  = var.repo_name
}

locals {
  existing_repo_url = try(data.aws_ecr_repository.existing[0].repository_url, null)
  repo_exists       = local.existing_repo_url != null
}

# ✅ Create only if repo does not exist
resource "aws_ecr_repository" "repo" {
  count = local.repo_exists ? 0 : 1

  name = var.repo_name

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }

  lifecycle {
    create_before_destroy = false
    prevent_destroy       = false
    ignore_changes        = [name, image_scanning_configuration]
  }
}

# ✅ Correct single-expression output block
output "repository_url" {
  value = local.repo_exists ? local.existing_repo_url : aws_ecr_repository.repo[0].repository_url
}
