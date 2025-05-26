#--------------------------------
# viberoll-infra/modules/rds/variables.tf
#--------------------------------
variable "db_name" {
  description = "Database name"
  type = string
}

variable "db_username" {
  description = "Database master username"  
  type = string
}

variable "db_password" {
  description = "Database master password"
  type      = string
  sensitive = true
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "project_name" {
  type = string
}