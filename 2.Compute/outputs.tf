output "alb_dns_name" {
  value       = aws_lb.external_alb.dns_name
  description = "ALB DNS Record"
}

output "asg_name" {
  value       = aws_autoscaling_group.app_asg.name
  description = "Auto Scaling Group Name"
}
