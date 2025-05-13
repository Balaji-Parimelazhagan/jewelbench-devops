terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.89.0"
    }
  }
}

# AWS Provider (Keep only one definition)
provider "aws" {
  region = var.region

  default_tags {
    tags = merge(var.AWS_TAGS, { Environment = var.environment })
  }
}


