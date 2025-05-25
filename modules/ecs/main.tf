# ------------------------------
# viberoll-infra/modules/ecs/main.tf
# ------------------------------
resource "aws_ecs_cluster" "this" {
  name = "${var.cluster_name}-cluster"
  tags = {
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"     # Minimal CPU for Free Tier eligible (0.25 vCPU)
  memory                   = "512"     # 0.5 GB memory to stay within Free Tier
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-app"
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = 4001
          hostPort      = 4001
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.project_name}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [container_definitions]
  }
}

resource "aws_ecs_service" "this" {
  name            = "${var.project_name}-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = var.private_subnets
    security_groups = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${var.project_name}-app"
    container_port   = 4001
  }

  depends_on = [var.alb_listener_arn]

  tags = {
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [desired_count, task_definition]
  }
}

resource "aws_iam_role" "execution_role" {
  name = "${var.project_name}-ecs-task-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_role_policy_attachment" "exec_policy" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

variable "cluster_name" {
  type = string
}

variable "container_image" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "alb_listener_arn" {
  type = string
}

variable "project_name" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}
