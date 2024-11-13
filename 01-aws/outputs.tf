# terraform output
# terraform output <output_name>
# terraform output -json
# terraform output -json > outputs.json

output "vpc_id" {
  description = "The ID of the VPC"
  value = aws_vpc.main.id
}

output "ec2_public_ip" {
  description = "The public IP of the EC2 instance"
  value = aws_instance.my_vm.public_ip
}

output "ami_id" {
  description = "The ID of the AMI"
  value = aws_instance.my_vm.ami
  sensitive = true
}
