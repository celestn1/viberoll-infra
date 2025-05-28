# ------------------------------
# viberoll-infra/modules/alb/outputs.tf
# ------------------------------

output "alb_arn" {
  value = var.create_alb ? aws_lb.alb[0].arn : var.alb_arn
}

output "alb_dns" {
  description = "The DNS name of the Application Load Balancer"
  # if we're creating the ALB ourselves, grab its DNS, otherwise empty
  value       = var.create_alb ? aws_lb.alb[0].dns_name : ""
}

output "target_group_arn" {
  value = aws_lb_target_group.tg.arn
}

output "listener_arn" {
  value = var.create_alb ? aws_lb_listener.http[0].arn : ""
}
