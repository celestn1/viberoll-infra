# ------------------------------
# viberoll-infra/modules/rds/main.tf
# ------------------------------

resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_security_group" "rds" {
  name   = "${var.project_name}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # VPC-local traffic only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = "${var.project_name}-postgres"
  engine                  = "postgres"
  engine_version          = "14.9"
  instance_class          = "db.t3.micro"                  # ✅ Free Tier eligible
  allocated_storage       = 20                             # ✅ Free Tier includes up to 20 GB
  db_name                 = var.db_name
  username                = var.username
  password                = var.password
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  skip_final_snapshot     = true                           # ✅ Avoids cost when deleting
  publicly_accessible     = false                          # ✅ Private only
  multi_az                = false                          # ✅ Avoid cross-AZ cost
  storage_encrypted       = true                           # ✅ Always recommended

  tags = {
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [parameter_group_name]
  }
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

variable "db_name" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "project_name" {
  type = string
}
