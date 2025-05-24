# ------------------------------
# viberoll-infra/outputs.tf
# ------------------------------
output "alb_dns" {
  value = module.alb.alb_dns
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ecr_repo_url" {
  value = module.ecr.repository_url
}
