# Require TF version to be same as or greater than 0.12.13
terraform {
  # required_version = ">=0.12.13"
  backend "s3" {
   bucket         = "terraform-backend-baniol"
   key            = "mkdocs-aws/terraform.tfstate"
   region         = "eu-central-1"
   dynamodb_table = "terraform-locks-baniol"
   encrypt        = true
  }
}

# Download any stable version in AWS provider of 2.36.0 or higher in 2.36 train
provider "aws" {
  region  = "eu-central-1"
  # version = "~> 2.36.0"
}