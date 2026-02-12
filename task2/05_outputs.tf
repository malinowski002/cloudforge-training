output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = "http://${aws_lb.app_alb.dns_name}"
}

# output "ec2_public_ip" {
#   description = "Public IP address of the EC2 instance"
#   value       = aws_instance.nginx_app.public_ip
# }

# output "ec2_private_ip" {
#   description = "Private IP address of the EC2 instance"
#   value       = aws_instance.nginx_app.private_ip
# }