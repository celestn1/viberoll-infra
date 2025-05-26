# ------------------------------
# viberoll-infra/modules/vpc/main.tf
# ------------------------------

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = {
    Name        = "${var.project_name}-vpc"
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = toset(var.azs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, index(var.azs, each.value))
  map_public_ip_on_launch = true
  availability_zone       = each.value

  tags = {
    Name        = "${var.project_name}-public-${each.value}"
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = toset(var.azs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, index(var.azs, each.value) + 10)
  availability_zone = each.value

  tags = {
    Name        = "${var.project_name}-private-${each.value}"
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id # use first public subnet

  tags = {
    Name = "${var.project_name}-nat-gw"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Route Table: Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }
}

# Associate Public Subnets
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Route Table: Private (with NAT)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name        = "${var.project_name}-private-rt"
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }
}

# Associate Private Subnets
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# Security Group: ALB
resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.main.id
  name   = "${var.project_name}-alb-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-alb-sg"
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }
}

# Security Group: ECS
resource "aws_security_group" "ecs" {
  vpc_id = aws_vpc.main.id
  name   = "${var.project_name}-ecs-sg"

  ingress {
    from_port       = 4001
    to_port         = 4001
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-ecs-sg"
    Project     = var.project_name
    Environment = "ephemeral"
    Expire      = "true"
  }
}

# Outputs
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnets" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "ecs_sg_id" {
  value = aws_security_group.ecs.id
}

variable "project_name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "azs" {
  type = list(string)
}
