output "vpc_id" {
  value       = aws_vpc.andrew_vpc.id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "Public Subnet IDs"
}

output "private_app_subnet_ids" {
  value       = aws_subnet.private_app[*].id
  description = "Private Subnet IDs"
}

output "isolated_data_subnet_ids" {
  value       = aws_subnet.isolated_data[*].id
  description = "Data Subnet IDs"
}

output "alb_sg_id" {
  value       = aws_security_group.alb_sg.id
  description = "Public facing ALB Security Group"
}

output "app_sg_id" {
  value       = aws_security_group.app_sg.id
  description = "Private Application Security Group"
}

output "bastion_sg_id" {
  value       = aws_security_group.bastion_sg.id
  description = "Bastion Host Security Group"
}
