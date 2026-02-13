terraform {
  cloud {

    organization = "cloudforge-training"

    workspaces {
      name = "cloudforge-training-workspace"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.24"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
