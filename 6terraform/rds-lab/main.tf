terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Re-use existing VPC — look it up by tag
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["devops-tf-vpc"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_security_group" "rds" {
  name   = "rds-sg"
  vpc_id = data.aws_vpc.main.id
}

# ── DB Subnet Group ──────────────────────────────────
resource "aws_db_subnet_group" "mysql" {
  name       = "devops-db-subnet-group"
  subnet_ids = data.aws_subnets.private.ids

  tags = {
    Name = "devops-db-subnet-group"
  }
}

# ── RDS Parameter Group — custom MySQL settings ──────
resource "aws_db_parameter_group" "mysql8" {
  name   = "devops-mysql8-params"
  family = "mysql8.0"

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "20"
  }

  tags = {
    Name = "devops-mysql-params"
  }
}

# ── RDS MySQL Instance ───────────────────────────────
resource "aws_db_instance" "mysql" {
  identifier     = "devops-lab-mysql"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = "devopslab"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [data.aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.mysql8.name

  multi_az                = false # true for production
  publicly_accessible     = false # NEVER true for production
  skip_final_snapshot     = true  # false for production
  backup_retention_period = 1

  tags = {
    Name  = "devops-lab-mysql"
    Owner = "Danish"
  }
}

output "rds_endpoint" {
  value     = aws_db_instance.mysql.endpoint
  sensitive = true
}
