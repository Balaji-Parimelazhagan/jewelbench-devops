terraform {
  backend "s3" {
    bucket         = "jewlbench-dev"
    key            = "dev/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
  }
}

