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

resource "aws_instance" "web" {
  ami           = "ami-0c02fb55956c7d316" # Ubuntu 22.04, us-east-1
  instance_type = var.instance_type

  tags = {
    Name    = "DevOps-Lab-EC2"
    Owner   = "Danish"
    Chapter = "Terraform"
    Purpose = "Terraform-Lab" # <-- new line
  }
}

# ── SNS Topic for alerts ─────────────────────────────
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1 # was 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60 # was 300 (1 minute instead of 5)
  statistic           = "Average"
  threshold           = 1 # was 80 (1% instead of 80%)

  alarm_description = "LAB ONLY: CPU above 1 percent for 1 minute — intentionally low for fast testing"
  alarm_actions     = [aws_sns_topic.alerts.arn]
  ok_actions        = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_instance.web.id
  }

  tags = {
    Name = "${var.project_name}-cpu-alarm"
  }
}

