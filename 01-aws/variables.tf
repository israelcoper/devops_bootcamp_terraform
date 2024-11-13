# Variable precedence:
# 1. -var and -var-file
# 2. terraform.tfvars
# 3. environment variables (TF_VAR_*)

variable "vpc_cidr_block" {
  default     = "20.0.0.0/16"
  description = "CIDR block for the VPC"
  type        = string
}

variable "web_subnet" {
  default     = "20.0.10.0/24"
  description = "CIDR block for the Web Subnet"
  type        = string
}

variable "subnet_zone" {
}

variable "main_vpc_name" {
}

variable "public_ip" {
}

variable "ssh_public_key" {
}
