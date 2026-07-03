terraform {
  backend "s3" {
    bucket       = "andrew-prod-remote-state-storage"
    key          = "network/terraform.tfstate" 
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
    profile      = "AdministratorAccess-169340963666"
  }
}
