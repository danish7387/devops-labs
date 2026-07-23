output "ec2_public_ip" {
  description = "Public IP address of the lab EC2 instance"
  value       = aws_instance.web.public_ip
}

output "ec2_instance_id" {
  description = "AWS instance ID of the lab EC2 instance"
  value       = aws_instance.web.id
}
