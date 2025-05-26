#-------------------------------
# viberoll-infra/modules/elasticache/variables.tf
#-------------------------------

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "project_name" {
  type = string
}
