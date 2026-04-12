#Allows us to access container that is behind alb
output "project_alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.project_application_lb.dns_name
}
