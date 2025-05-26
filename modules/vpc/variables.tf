# ------------------------------
# viberoll-infra/modules/vpc/variables.tf
# ------------------------------
variable "project_name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "azs" {
  type = list(string)
}
