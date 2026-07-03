# Secondary Analytics VPC
resource "aws_vpc" "analytics_vpc" {
  cidr_block           = "10.201.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "andrew-analytics-vpc" }
}

# Establish the Peering Request from Prod VPC to Analytics VPC
resource "aws_vpc_peering_connection" "prod_to_analytics" {
  vpc_id        = aws_vpc.andrew_vpc.id
  peer_vpc_id   = aws_vpc.analytics_vpc.id
  auto_accept   = true # Valid when both VPCs reside within the same AWS account

  tags = {
    Name = "andrew-peering-prod-analytics"
  }
}

# Update Prod Route Table to point analytics traffic through the peering connection
resource "aws_route" "prod_to_analytics_route" {
  route_table_id            = aws_route_table.private[0].id 
  destination_cidr_block    = aws_vpc.analytics_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.prod_to_analytics.id
}

# Update Analytics Route Table to point return traffic back to Prod
resource "aws_route" "analytics_to_prod_route" {
  route_table_id            = aws_vpc.analytics_vpc.default_route_table_id
  destination_cidr_block    = aws_vpc.andrew_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.prod_to_analytics.id
}
