#------------------------------
# viberoll-infra/modules/ecr/outputs.tf
#------------------------------

output "repository_url" {
  value = local.repo_exists ? local.existing_repo_url : aws_ecr_repository.repo[0].repository_url
}
