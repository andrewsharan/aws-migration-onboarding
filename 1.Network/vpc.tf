# Core VPC
resource "aws_vpc" "andrew_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "andrew-prod-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "andrew_igw" {
  vpc_id = aws_vpc.andrew_vpc.id

  tags = {
    Name = "andrew-prod-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.andrew_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index) 
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name                     = "andrew-prod-public-subnet-${var.availability_zones[count.index]}"
    "kubernetes.io/role/elb" = "1" 
  }
}

# Private Application Subnets
resource "aws_subnet" "private_app" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.andrew_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 1)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                              = "andrew-prod-private-app-subnet-${var.availability_zones[count.index]}"
    "kubernetes.io/role/internal-elb" = "1" 
  }
}

# Isolated Data Subnets
resource "aws_subnet" "isolated_data" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.andrew_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 6, count.index + 16) 
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "andrew-prod-isolated-data-subnet-${var.availability_zones[count.index]}"
  }
}


# Allocate Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "andrew-prod-nat-eip"
  }
}

# Provision the NAT Gateway inside Public Subnet A
resource "aws_nat_gateway" "andrew_nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "andrew-prod-natgw-shared"
  }

  depends_on = [aws_internet_gateway.andrew_igw]
}


# Public Route Table pointing to the Internet Gateway 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.andrew_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.andrew_igw.id
  }

  tags = {
    Name = "andrew-prod-public-rt"
  }
}

# Private Route Table pointing to NAT gateway to the NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.andrew_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.andrew_nat.id
  }

  tags = {
    Name = "andrew-prod-private-shared-rt"
  }
}

# Data Route Table with no routes
resource "aws_route_table" "isolated" {
  vpc_id = aws_vpc.andrew_vpc.id

  tags = {
    Name = "andrew-prod-isolated-rt"
  }
}

# Public Subnet Association to Public Route Table
resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Subnet Association to Private Route Table
resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private.id
}

# Data Subnet Association to Data Route Table
resource "aws_route_table_association" "isolated" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.isolated_data[count.index].id
  route_table_id = aws_route_table.isolated.id
}

