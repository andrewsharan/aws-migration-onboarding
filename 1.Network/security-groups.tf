# Load Balancer Security Group (Public Subnet)
resource "aws_security_group" "alb_sg" {
  name        = "andrew-prod-alb-sg"
  description = "Public facing ALB Security Group"
  vpc_id      = aws_vpc.andrew_vpc.id

  ingress {
    description = "Allow TLS from public internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound to private subnet  workloads"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "andrew-prod-alb-sg" }
}

# Application Security Group (Private Subnet)
resource "aws_security_group" "app_sg" {
  name        = "andrew-prod-app-sg"
  description = "Private Application Subnet Security Group"
  vpc_id      = aws_vpc.andrew_vpc.id

  ingress {
    description     = "Allow web traffic only from the ALB security group"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow outbound traffic via NAT Gateway for external API calls"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "andrew-prod-app-sg" }
}

# Data Security Group (Data Subnet)
resource "aws_security_group" "db_sg" {
  name        = "andrew-prod-db-sg"
  description = "Air-gapped database tier security rules"
  vpc_id      = aws_vpc.andrew_vpc.id

  ingress {
    description     = "Allow database queries from verified private subnet workloads"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  ingress {
    description     = "Allow to query DB using Bastion Host"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    description = "Prevent database from initiating outbound network calls"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.andrew_vpc.cidr_block]
  }

  tags = { Name = "andrew-prod-db-sg" }
}
