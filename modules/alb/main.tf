# ------------------------------
# viberoll-infra/modules/alb/main.tf
# ------------------------------

variable "create_alb" {
  type        = bool
  description = "Whether to create a new ALB or assume it already exists"
  default     = true
}

variable "alb_arn" {
  type        = string
  description = "ARN of existing ALB to use if not creating a new one"
  default     = ""
}

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

# ➕ Create ALB conditionally
resource "aws_lb" "alb" {
  count              = var.create_alb ? 1 : 0
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

# ➕ Target Group
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

# ➕ Listener – only created if ALB is managed by Terraform
resource "aws_lb_listener" "http" {
  count             = var.create_alb ? 1 : 0
  load_balancer_arn = aws_lb.alb[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# 🧾 Outputs – resolve dynamically whether ALB was created or passed in
output "alb_arn" {
  value = var.create_alb ? aws_lb.alb[0].arn : var.alb_arn
}

output "alb_dns" {
  value = var.create_alb ? aws_lb.alb[0].dns_name : ""
}

output "target_group_arn" {
  value = aws_lb_target_group.tg.arn
}

output "listener_arn" {
  value = var.create_alb ? aws_lb_listener.http[0].arn : ""
}
