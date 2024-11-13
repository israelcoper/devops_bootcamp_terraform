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

variable "ami_id" {
  description = "The ID of the AMI"
  type        = string
  default     = "ami-04b6019d38ea93034"
}

# Create an EC2 Instance (Amazon Linux 2)
resource "aws_instance" "server" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  count         = 1

  tags = {
    "Name" = "Amazon Linux 2"
  }
}

# Command/Configuration to display logs for troubleshooting purposes
# export TF_LOG=DEBUG
# export TF_LOG_PATH=terraform.log
# export TF_LOG_CORE=info
# export TF_LOG_PROVIDER=debug
