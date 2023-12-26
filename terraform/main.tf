terraform {
  // Ensures that everyone is using a specific Terraform version
  required_version = ">= 1.6.0"

  // Where Terraform stores its state to keep track of the resources it manages
  backend "s3" {
    bucket = "040209405785-app-infra-state"
    key    = "terraform.tfstate"
    region = "us-west-1"
  }

  // Declares providers, so that Terraform can install and use them
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
}

// Specify settings for a given required provider
provider "aws" {
  region = "us-west-1"
}
