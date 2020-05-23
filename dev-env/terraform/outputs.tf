output "dev_instance_public_ip" {
  description = "Public IP addresses assigned to the instances, if applicable"
  value = aws_instance.dev.public_ip
}

output "dev_instance_public_dns" {
  description = "Public DNS assigned to the instances, if applicable"
  value = aws_instance.dev.public_dns
}

output "lambda_goodnight_function_name" {
  description = " Lambda function name of goodnight"
  value = aws_lambda_function.goodnight.function_name
}
