data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket       = "andrew-prod-remote-state-storage"
    key          = "network/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    profile      = "AdministratorAccess-169340963666"
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-minimal-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
