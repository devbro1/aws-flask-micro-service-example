terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.33.0"
    }
  }
}

provider "aws" {
  region = "ca-central-1"
  default_tags {
    tags = {
      Environment = "testing"
      CreatedBy   = "Terraform"
    }
  }
}