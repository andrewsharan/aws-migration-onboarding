# Virtual Private Cloud
resource "aws_vpc" "andrew_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "andrew-prod-vpc"
  }
}

# Internet Gateway for Public Routing
resource "aws_internet_gateway" "andrew_igw" {
  vpc_id = aws_vpc.andrew_vpc.id

  tags = {
    Name = "andrew-prod-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.andrew_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                     = "andrew-prod-public-subnet-${var.availability_zones[count.index]}"
    "kubernetes.io/role/elb" = "1" 
  }
}

# Private Application Subnet
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

# Isolated Data Subnet 
resource "aws_subnet" "isolated_data" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.andrew_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 6, count.index + 16) 
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "andrew-prod-isolated-data-subnet-${var.availability_zones[count.index]}"
  }
}

# Elastic IPs and NAT Gateway (One Per AZ)
resource "aws_eip" "nat" {
  count  = length(var.availability_zones)
  domain = "vpc"

  tags = {
    Name = "andrew-prod-nat-eip-${var.availability_zones[count.index]}"
  }
}

resource "aws_nat_gateway" "andrew_nat" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "andrew-prod-natgw-${var.availability_zones[count.index]}"
  }
  depends_on = [aws_internet_gateway.andrew_igw]
}

# Explicit Route Tables Configuration
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

resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.andrew_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.andrew_nat[count.index].id
  }

  tags = {
    Name = "andrew-prod-private-rt-${var.availability_zones[count.index]}"
  }
}

resource "aws_route_table" "isolated" {
  vpc_id = aws_vpc.andrew_vpc.id

  tags = {
    Name = "andrew-prod-isolated-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "isolated" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.isolated_data[count.index].id
  route_table_id = aws_route_table.isolated.id
}
