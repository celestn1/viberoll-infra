# ------------------------------
# viberoll-infra/main.tf
# ------------------------------

provider "aws" {
  region = var.aws_region
}

locals {
  base_secrets = var.secrets_map

  secrets_map = merge(local.base_secrets, {
    DATABASE_URL = "postgres://${var.db_username}:${var.db_password}@${module.rds_endpoint}:5432/${var.db_name}"
    REDIS_URL    = "redis://${module.elasticache.redis_endpoint}:6379"
  })

  common_tags = {
    Project     = var.project_name
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  cidr_block   = var.vpc_cidr
  azs          = var.azs
}

module "ecr" {
  source       = "./modules/ecr"
  repo_name    = var.ecr_repo_name
  project_name = var.project_name
}

module "alb" {
  source             = "./modules/alb"
  create_alb         = true
  alb_arn            = ""
  vpc_id             = module.vpc.vpc_id
  public_subnets     = module.vpc.public_subnets
  security_group_ids = [module.vpc.alb_sg_id]
  project_name       = var.project_name
}

module "ecs" {
  source             = "./modules/ecs"
  cluster_name       = var.project_name
  container_image    = var.container_image
  private_subnets    = module.vpc.private_subnets
  security_group_ids = [module.vpc.ecs_sg_id]
  target_group_arn   = module.alb.target_group_arn
  alb_listener_arn   = module.alb.listener_arn
  project_name       = var.project_name
  secret_arns        = module.secrets.secret_arns
}

module "rds" {
  source       = "./modules/rds"
  db_name      = var.db_name
  db_username  = var.db_username
  db_password  = var.db_password
  subnet_ids   = module.vpc.private_subnets
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
}

module "elasticache" {
  source       = "./modules/elasticache"
  subnet_ids   = module.vpc.private_subnets
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
}

module "secrets" {
  source       = "./modules/secrets"
  secrets_map  = local.secrets_map
  project_name = var.project_name
  tags         = local.common_tags
}

module "waf" {
  source       = "./modules/waf"
  alb_arn      = module.alb.alb_arn
  project_name = var.project_name
}

module "cloudwatch" {
  source         = "./modules/cloudwatch"
  log_group_name = "/ecs/${var.project_name}"
  project_name   = var.project_name
}