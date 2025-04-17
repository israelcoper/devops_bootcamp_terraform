output "instance_id" {
  description = "AWS instance id"
  value       = aws_instance.web_server.id
}

output "instance_public_ip" {
  description = "AWS instance public ip"
  value       = aws_instance.web_server.public_ip
}