# ------------------------------
# viberoll-infra/modules/ecr/main.tf
#------------------------------

resource "aws_ecr_repository" "repo" {
  name = var.repo_name

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Project = var.project_name
  }
}

output "repository_url" {
  value = aws_ecr_repository.repo.repository_url
}

variable "repo_name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "project_name" {
  type        = string
  description = "Project name used for tagging"
}
