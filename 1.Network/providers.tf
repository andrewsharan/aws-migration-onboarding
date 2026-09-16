terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "AdministratorAccess"


  # Enforce consistent tagging across all resources
  default_tags {
    tags = {
      Project     = "andrew"
      Environment = "production"
      ManagedBy   = "terraform"
      Layer       = "Network"
    }
  }
}
