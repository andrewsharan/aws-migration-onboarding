output "vpc_id" {
  value       = aws_vpc.andrew_vpc.id
  description = "Production VPC ID"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "Public Subnet IDs"
}

output "private_app_subnet_ids" {
  value       = aws_subnet.private_app[*].id
  description = "Private Application Subnet IDs"
}

output "isolated_data_subnet_ids" {
  value       = aws_subnet.isolated_data[*].id
  description = "Isolated Data Subnet IDs"
}
