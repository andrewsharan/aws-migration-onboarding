# Create the Central Hub Cloud Router
resource "aws_ec2_transit_gateway" "andrew_tgw" {
  description                     = "Central transit routing engine for Andrew enterprise infrastructure"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"

  tags = {
    Name = "andrew-main-tgw"
  }
}

# Attach the Andrew Production VPC to the Transit Gateway hub
resource "aws_ec2_transit_gateway_vpc_attachment" "prod_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.andrew_tgw.id
  vpc_id             = aws_vpc.andrew_vpc.id
  
  # Attach to the private subnets across multiple AZs for built-in high availability
  subnet_ids = aws_subnet.private_app[*].id

  tags = {
    Name = "andrew-tgw-prod-vpc-attachment"
  }
}
