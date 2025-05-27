#--------------------------------
# viberoll-infra/modules/ecr/main.tf
#--------------------------------
# 🔍 Lookup existing ECR repo if enabled
data "aws_ecr_repository" "existing" {
  count = var.repo_check_enabled ? 1 : 0
  name  = var.repo_name
}

locals {
  existing_repo_url = try(data.aws_ecr_repository.existing[0].repository_url, null)
  repo_exists       = local.existing_repo_url != null
}

# 📦 Create new ECR repo only if not found
resource "aws_ecr_repository" "repo" {
  count = local.repo_exists ? 0 : 1
  name  = var.repo_name

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
    prevent_destroy       = false  # ✅ Use hardcoded value
    create_before_destroy = false
    ignore_changes        = [name, image_scanning_configuration]
  }
}
