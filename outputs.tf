# ------------------------------
# viberoll-infra/outputs.tf
# ------------------------------
output "alb_dns" {
  description = "Public DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "ecr_repo_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "rds_endpoint" {
  description = "RDS PostgreSQL database endpoint"
  value       = module.rds.rds_endpoint
}

output "redis_endpoint" {
  description = "ElastiCache Redis endpoint"
  value       = module.elasticache.redis_endpoint
}

output "secrets_manager_arns" {
  description = "ARNs of secrets created in AWS Secrets Manager"
  value       = module.secrets.secret_arns
}
