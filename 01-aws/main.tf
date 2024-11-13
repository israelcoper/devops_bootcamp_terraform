# Terrarform Commands
# terraform init
# terraform plan
# terraform plan -var="web_subnet=10.0.20.0/24"
# terraform plan -var-file=production.tfvars
# terraform plan -replace="aws_instance.my_vm"
# terraform apply
# terraform apply -replace="aws_instance.my_vm" -auto-approve
# terraform destroy -target <provider>_<resource_type>.local_name -auto-approve
# terraform destroy -target aws_vpc.my_vpc -auto-approve
# terraform fmt
# terraform fmt --diff -check
# terraform fmt -recursive
# terraform validate
# terraform show // display all the resources and output values contained in the state file
# terraform state list // display a list of resource types and local names saved in the state
# terraform state show <resource_type>.local_name

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

# resource "<provider>_<resource_type>" "local_name" {
#   argument1 = "value1"
#   argument2 = "value2"
# }

# Create a VPC
resource "aws_vpc" "main" {
  # cidr_block = "10.0.0.0/16"
  cidr_block = var.vpc_cidr_block

  tags = {
    # "Name" = "Main VPC"
    "Name" = "Production ${var.main_vpc_name}"
  }
}

# 2nd VPC
# resource "aws_vpc" "my_vpc" {
#   cidr_block = "10.0.0.0/16"

#   tags = {
#     "Name" = "My VPC"
#   }
# }

# Create a Subnet
resource "aws_subnet" "web" {
  vpc_id = aws_vpc.main.id
  # cidr_block = "10.0.10.0/24"
  # availability_zone = "ap-southeast-1a"
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

# Generate ssh key pair
# ssh-keygen -t rsa -b 2048 -C 'test key' -N '' -f ~/.ssh/test_rsa

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

# Create an EC2 Instance
resource "aws_instance" "my_vm" {
  # ami           = "ami-04b6019d38ea93034"
  ami          = data.aws_ami.latest_amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.web.id
  vpc_security_group_ids = [aws_default_security_group.main_vpc_default_sg.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh_key_test_00.key_name
  # user_data = <<-EOF
  #             #!/bin/bash
  #             sudo yum -y update && yum -y install httpd
  #             sudo systemctl start httpd && sudo systemctl enable httpd
  #             sudo echo "<h1>Deployed via Terraform</h1>" > /var/www/html/index.html
  #             EOF
  # user_data = file("entry-script.sh")

  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file("/home/plashspeed/.ssh/test_rsa")
  }

  provisioner "file" {
    source = "./entry-script.sh"
    destination = "/home/ec2-user/entry-script.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /home/ec2-user/entry-script.sh",
      "sudo /home/ec2-user/entry-script.sh",
      "exit"
     ]
     on_failure = continue
  }

  tags = {
    "Name" = "My EC2 Instance - Amazon Linux 2023"
  }
}
