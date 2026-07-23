variable "instance_type" {
  description = "EC2 instance type for the lab server"
  type        = string
  default     = "t3.micro"
}

variable "project_name" {
  description = "Project name prefix for resource naming"
  type        = string
  default     = "devops-lab"
}

variable "alert_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
}
