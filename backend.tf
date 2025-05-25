# ------------------------------
# viberoll-infra/backend.tf
# ------------------------------
terraform {
  backend "s3" {
    bucket         = "viberoll-terraform-state-02"
    key            = "prod/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "viberoll-locks"
    encrypt        = true
  }
}