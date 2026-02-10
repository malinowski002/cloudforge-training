terraform { 
  cloud { 
    
    organization = "cloudforge-training" 

    workspaces { 
      name = "cloudforge-training-workspace" 
    } 
  }

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = "eu-north-1"

    default_tags {
        tags = {
            project = "static-website"
        }
    }
}