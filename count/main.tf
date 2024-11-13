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
# resource "aws_instance" "server" {
#   ami = "ami-04b6019d38ea93034"
#   instance_type = "t2.micro"
#   count = 3
# }

# Create IAM user
# resource "aws_iam_user" "test" {
#   name = "x-user"
#   path = "/system/"
# }

# Create IAM users
# resource "aws_iam_user" "test" {
#   name = "x-user-${count.index}"
#   path = "/system/"
#   count = 5
# }
variable "users" {
  type = list(string)
  default = ["demo-user", "admin1", "john"]
}

# Using count
# resource "aws_iam_user" "test" {
#   name = "${element(var.users, count.index)}"
#   path = "/system/"
#   count = length(var.users)
# }

# count is sensitive to the order of the resources
# count is sensitive to any changes in list order

# Using for_each
resource "aws_iam_user" "test" {
  for_each = toset(var.users)
  name = each.key
  path = "/system/"
}

# there is no order of the resources under for_each
# creating and destroying individual resources leaves all the other in their proper place
