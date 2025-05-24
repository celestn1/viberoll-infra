# ------------------------------
# viberoll-infra/backend.tf
# ------------------------------
terraform {
  backend "s3" {
    bucket         = "viberoll-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "viberoll-locks"
    encrypt        = true
  }
}