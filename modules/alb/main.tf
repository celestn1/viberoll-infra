# ------------------------------
# viberoll-infra/modules/alb/main.tf
# ------------------------------

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "project_name" {
  type = string
}

variable "force_create_alb" {
  type    = bool
  default = false
}

# Attempt to find an existing ALB with this name
data "aws_lb" "existing" {
  name = "${var.project_name}-alb"
}

locals {
  existing_alb_arn = try(data.aws_lb.existing.arn, null)
  alb_exists       = local.existing_alb_arn != null
  use_existing     = !var.force_create_alb && local.alb_exists
  alb_arn          = local.use_existing ? local.existing_alb_arn : aws_lb.alb[0].arn
}

resource "aws_lb" "alb" {
  count              = local.use_existing ? 0 : 1
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.public_subnets

  tags = {
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [name, tags]
  }
}

resource "aws_lb_target_group" "tg" {
  name        = "${var.project_name}-tg"
  port        = 4001
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [name, tags]
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = local.alb_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

output "alb_arn" {
  value = local.alb_arn
}

output "alb_dns" {
  value = local.use_existing ? data.aws_lb.existing.dns_name : aws_lb.alb[0].dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.tg.arn
}

output "listener_arn" {
  value = aws_lb_listener.http.arn
}
