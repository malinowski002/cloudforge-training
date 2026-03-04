terraform {
  required_version = ">= 1.5.0"
  backend "s3" {
    bucket         = "eks-state-l5ghv"
    key            = "eks-cluster/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-lock"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      project = "static-website"
    }
  }
}