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

# IAM Role for ECS task execution
resource "aws_iam_role" "execution_role" {
  name = "${var.project_name}-ecs-exec-role"

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
}

resource "aws_iam_role_policy_attachment" "exec_policy" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional inline policy to allow access to secrets
resource "aws_iam_policy" "secrets_access" {
  name = "${var.project_name}-ecs-secrets-access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}-*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  role       = aws_iam_role.execution_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}

data "aws_caller_identity" "current" {}

# IAM Role for application-level permissions
resource "aws_iam_role" "task_role" {
  name = "${var.project_name}-ecs-task-role"

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
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-app",
      image     = var.container_image,
      essential = true,

      portMappings = [
        {
          containerPort = 4001,
          hostPort      = 4001
        }
      ],

      # ← Updated: iterate map with key,value
      environment = [
        for env_name, env_value in var.environment : {
          name  = env_name
          value = env_value
        }
      ],

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/${var.project_name}",
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = var.project_name
        }
      },

      secrets = [
        for key, arn in var.secret_arns : {
          name      = key,
          valueFrom = arn
        }
      ]
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
  desired_count   = 1

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${var.project_name}-app"
    container_port   = 4001
  }

  health_check_grace_period_seconds = 60
  depends_on                        = [var.alb_listener_arn]

  force_new_deployment = true

  tags = {
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [desired_count]
  }
}