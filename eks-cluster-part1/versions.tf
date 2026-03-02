terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  cloud {
    organization = "cloudforge-training"

    workspaces {
      name = "cloudforge-training-workspace"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
