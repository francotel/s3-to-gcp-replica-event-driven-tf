terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82"
    }
    google = {
      source  = "hashicorp/google"
      version = "6.16.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "google" {
  region                = var.gcp-region
  user_project_override = true
}

provider "aws" {
  profile = var.aws-profile
  region  = var.aws-region

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}
