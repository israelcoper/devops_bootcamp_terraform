# Concept notes:
# Cloud-init is the standard for customizing cloud instances
# It runs on most Linux distributions and cloud providers
# It can run "per-instance" or "per-boot" configuration

# Terraform commands
# terraform import aws_key_pair.ssh_key_test_00 ssh_key_test_00

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

# Create a VPC
resource "aws_vpc" "main" {
  # cidr_block = "10.0.0.0/16"
  cidr_block = var.vpc_cidr_block

  tags = {
    # "Name" = "Main VPC"
    "Name" = "Production ${var.main_vpc_name}"
  }
}

# Create a Subnet
resource "aws_subnet" "web" {
  vpc_id = aws_vpc.main.id
  cidr_block        = var.web_subnet
  availability_zone = var.subnet_zone
  tags = {
    "Name" = "Web Subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "web_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.main_vpc_name} IGW"
  }
}

# Create a Default Route Table
resource "aws_default_route_table" "main_vpc_default_rt" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_igw.id
  }
  tags = {
    "Name" = "my-default-rt"
  }
}

# Create Default Security Group
resource "aws_default_security_group" "main_vpc_default_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = [var.public_ip]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1" # any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "main-vpc-default-sg"
  }
}

# Create Key Pair
resource "aws_key_pair" "ssh_key_test_00" {
  key_name   = "ssh_key_test_00"
  public_key = file(var.ssh_public_key)
}

# Fetch the latest Amazon Linux 2 AMI
data "aws_ami" "latest_amazon_linux_2" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
  filter  {
    name = "architecture"
    values = ["x86_64"]
  }
}

data "template_file" "user_data" {
  template = file("web-app-template.yaml")
}

# Create an EC2 Instance
resource "aws_instance" "my_vm" {
  ami          = data.aws_ami.latest_amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.web.id
  vpc_security_group_ids = [aws_default_security_group.main_vpc_default_sg.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh_key_test_00.key_name
  user_data = data.template_file.user_data.rendered

  tags = {
    "Name" = "My EC2 Instance - Amazon Linux 2023"
  }
}
