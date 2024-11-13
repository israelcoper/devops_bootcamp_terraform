variable "web_port" {
  description = "Web port"
  type = number
  default = 80
}

variable "aws_region" {
  description = "AWS region"
  type = string
  default = "ap-southeast-1"
}

variable "enable_dns_support" {
  description = "DNS support for the VPC"
  type = bool
  default = true
}

variable "availability_zones" {
  description = "Availability zones in the region"
  type = list(string)
  default = ["ap-southeast-1a", "ap-southeast-1b"]
}

# type map
variable "amis" {
  description = "AMI IDs for the region"
  type = map(string)
  default = {
    "ap-southeast-1" = "ami-04b6019d38ea93034"
  }
}

variable "my_instance" {
  type = tuple([string, number, bool])
  default = ["t2.micro", 1, true]
}

variable "egress_default_security_group" {
  type = object({
    from_port = number
    to_port = number
    protocol = string
    cidr_blocks = list(string)
  })
  default = {
    from_port = 0
    to_port = 65365
    protocol = "tcp"
    cidr_blocks = ["100.0.0.0/16", "200.0.0.0/16"]
  }
}
