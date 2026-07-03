# Public Subnet NACL
resource "aws_network_acl" "public_nacl" {
  vpc_id     = aws_vpc.andrew_vpc.id
  subnet_ids = aws_subnet.public[*].id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  #  Allows return traffic from AWS SSM Endpoint APIs back into the public subnet (Bastion)
  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = { Name = "andrew-prod-public-nacl" }
}

# Private Application Subnet NACL
resource "aws_network_acl" "private_app_nacl" {
  vpc_id     = aws_vpc.andrew_vpc.id
  subnet_ids = aws_subnet.private_app[*].id

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = aws_vpc.andrew_vpc.cidr_block
    from_port  = 0
    to_port    = 0
  }

  # Allows return web traffic back into private nodes from public NAT calls
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = { Name = "andrew-prod-private-app-nacl" }
}
