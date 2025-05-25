# ------------------------------
# viberoll-infra/modules/alb/main.tf
# ------------------------------

resource "aws_lb" "alb" {
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
  target_type = "ip" # Required for Fargate

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
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  depends_on = [aws_lb_target_group.tg]
}

output "alb_arn" {
  value = aws_lb.alb.arn
}

output "alb_dns" {
  value = aws_lb.alb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.tg.arn
}

output "listener_arn" {
  value = aws_lb_listener.http.arn
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
