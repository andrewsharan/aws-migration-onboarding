# Public Subnet NACL - Allows public web traffic and outbound responses
resource "aws_network_acl" "public_nacl" {
  vpc_id     = aws_vpc.andrew_vpc.id
  subnet_ids = aws_subnet.public[*].id

  # Inbound: Allow HTTP traffic from anywhere
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # Inbound: Allow HTTPS traffic from anywhere
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Inbound: Allow return traffic from ephemeral ports
  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Outbound: Allow all outbound traffic to the internet
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "andrew-prod-public-nacl"
  }
}

# Private Application Subnet NACL - Completely blocks direct public access
resource "aws_network_acl" "private_app_nacl" {
  vpc_id     = aws_vpc.andrew_vpc.id
  subnet_ids = aws_subnet.private_app[*].id

  # Inbound: Allow traffic from the VPC CIDR block only
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = aws_vpc.andrew_vpc.cidr_block
    from_port  = 0
    to_port    = 0
  }

  # Inbound: Allow return ephemeral port traffic from external internet APIs via NAT Gateway
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Outbound: Allow all internal and external outbound traffic
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "andrew-prod-private-app-nacl"
  }
}
