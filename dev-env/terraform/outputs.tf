output "dev_instance_public_ip" {
  description = "Public IP addresses assigned to the instances, if applicable"
  value = aws_instance.dev.public_ip
}

output "dev_instance_public_dns" {
  description = "Public DNS assigned to the instances, if applicable"
  value = aws_instance.dev.public_dns
}
