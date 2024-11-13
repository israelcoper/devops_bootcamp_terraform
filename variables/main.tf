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
  region  = var.aws_region
  profile = "aws-admin"
}

# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = var.enable_dns_support

  tags = {
    "Name" = "Main VPC"
  }
}

# Create a Subnet
resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.10.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    "Name" = "web-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_web_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    "Name" = "web-igw"
  }
}

# Associate the IGW to the default Route Table
resource "aws_default_route_table" "main_vpc_default_rt" {
  default_route_table_id = aws_vpc.main_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_web_igw.id
  }

  tags = {
    "Name" = "main-vpc-default-rt"
  }
}

# Setting default security group
resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = var.web_port
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = var.egress_default_security_group["from_port"]
    to_port = var.egress_default_security_group["to_port"]
    protocol = var.egress_default_security_group["protocol"]
    cidr_blocks = var.egress_default_security_group["cidr_blocks"]
  }

  tags = {
    "Name" = "default-sg"
  }
}

# Create an EC2 Instance (Amazon Linux 2)
resource "aws_instance" "server" {
  ami           = var.amis[var.aws_region]
  instance_type = var.my_instance[0]
  # cpu_core_count = var.my_instance[1]
  associate_public_ip_address = var.my_instance[2]
  count         = 1

  tags = {
    "Name" = "Amazon Linux 2"
  }
}
