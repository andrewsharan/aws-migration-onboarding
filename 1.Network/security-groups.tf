# Load Balancer Security Group - Public Subnet
resource "aws_security_group" "alb_sg" {
  name        = "andrew-prod-alb-sg"
  description = "Public Facing ALB Security Group"
  vpc_id      = aws_vpc.andrew_vpc.id

  ingress {
    description = "Allow TLS from public internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic to internal workloads"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "andrew-prod-alb-sg"
  }
}

# Application Security Group - Private Application Subnet
resource "aws_security_group" "app_sg" {
  name        = "andrew-prod-app-sg"
  description = "Private Application Security Group"
  vpc_id      = aws_vpc.andrew_vpc.id

  ingress {
    description     = "Strictly allow web traffic only from the ALB security group"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] 
  }

  egress {
    description = "Allow outbound traffic for patching or external API calls"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "andrew-prod-app-sg"
  }
}

# Database Security Group - Isolated Subnet
resource "aws_security_group" "db_sg" {
  name        = "andrew-prod-db-sg"
  description = "Isolated Database Security Group"
  vpc_id      = aws_vpc.andrew_vpc.id

  ingress {
    description     = "Allow database queries strictly from private application security group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    description = "Prevent database from initiating outbound network calls"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.andrew_vpc.cidr_block] 
  }

  tags = {
    Name = "andrew-prod-db-sg"
  }
}
