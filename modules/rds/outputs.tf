#-------------------------
# viberoll-infra/modules/rds/outputs.tf
#-------------------------

output "rds_address" {
  value = aws_db_instance.postgres.address
}
