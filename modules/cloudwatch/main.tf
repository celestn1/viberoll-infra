# ------------------------------
# viberoll-infra/modules/cloudwatch/main.tf
# ------------------------------

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = var.log_group_name
  retention_in_days = 1 # Keep logs only for 1 day to stay within Free Tier

  tags = {
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }
}

