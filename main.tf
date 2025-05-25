# ------------------------------
# viberoll-infra/main.tf
# ------------------------------

provider "aws" {
  region = var.aws_region
}

# ----------------------------------------
# Locals: Dynamic secrets (referenced from terraform.tfvars)
# ----------------------------------------
locals {
  secrets_map = {
    # APPLICATION SETTINGS
    NODE_ENV                     = "production"
    HOST                         = "http://localhost:"
    PORT                         = "4001"

    # DATABASE CONFIGURATION
    DATABASE_URL = "postgres://${var.db_username}:${var.db_password}@${module.rds.rds_endpoint}:5432/${var.db_name}"
    REDIS_URL    = "redis://${module.elasticache.redis_endpoint}:6379"

    # JWT AUTHENTICATION
    JWT_SECRET                    = var.jwt_secret
    JWT_REFRESH_SECRET            = var.jwt_refresh_secret
    SALT_ROUNDS                   = "10"
    JWT_ACCESS_TOKEN_EXPIRATION  = "24h"
    JWT_REFRESH_TOKEN_EXPIRATION = "7d"

    # BLOCKCHAIN CONFIGURATION
    RPC_URL              = "https://polygon-rpc.com"
    WALLET_PRIVATE_KEY   = var.wallet_private_key
    NFT_CONTRACT_ADDRESS = var.nft_contract_address

    # OPENAI API CONFIGURATION
    OPENAI_API_ENDPOINT = "https://api.openai.com/v1/engines/davinci/completions"
    OPENAI_API_KEY      = var.openai_api_key

    # ADMIN SEED ACCOUNT
    ADMIN_EMAIL    = var.admin_email
    ADMIN_PASSWORD = var.admin_password
    ADMIN_USERNAME = var.admin_username
  }
}

# ----------------------------------------
# Modules
# ----------------------------------------

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
}

module "rds" {
  source       = "./modules/rds"
  db_name      = var.db_name
  username     = var.db_username
  password     = var.db_password
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
