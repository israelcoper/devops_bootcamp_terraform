# Terraform Commands
# terraform apply -replace='aws_instance.server'

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "ap-southeast-1"
  profile = "aws-admin"
}

# Create an EC2 instance
resource "aws_instance" "server" {
  ami           = "ami-04b6019d38ea93034"
  instance_type = "t2.micro"
}
