# ------------------------------------------------- #
# Bastion Host Security Group (No Inbound Access)   #
# ------------------------------------------------- #

resource "aws_security_group" "bastion_sg" {
  name        = "andrew-prod-bastion-sg"
  description = "Security group for SSM-managed bastion host"
  vpc_id      = aws_vpc.andrew_vpc.id

  egress {
    description = "Allow outbound access to AWS services"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "andrew-prod-bastion-sg"
  }
}

# ---------------------------------- #
# IAM Role for AWS Systems Manager   #
# ---------------------------------- #

resource "aws_iam_role" "bastion_ssm_role" {
  name = "andrew-prod-bastion-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.bastion_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "andrew-prod-bastion-instance-profile"
  role = aws_iam_role.bastion_ssm_role.name
}

# --------------------- #
# Amazon Linux 2023 AMI #
# --------------------- #

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# -------------- #
# Bastion Host   #
# -------------- #

resource "aws_instance" "bastion" {
  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = "t3.nano"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name

  associate_public_ip_address = true

  # CPU credit safety
  credit_specification {
    cpu_credits = "standard"
  }

  # Enforce IMDSv2 
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    volume_size = 15
    volume_type = "gp3"
  }

  tags = {
    Name = "andrew-prod-bastion-host"
  }
}
