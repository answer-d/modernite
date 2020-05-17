variable "prefix_name" {
  description = "String to be prepended to the resource name"
}

variable "system_name" {
  description = "String to be inserted to the resource name"
}

variable "stage" {
  description = "System stage"
}

variable "author" {
  description = "The value of the tag `Author` to be assigned to all resources"
}

variable "vpc_cidr" {
  description = "Cidr block for vpc"
}

variable "public_subnet_cidr_block" {
  description = "Cidr block for public subnet"
}

variable "key_name" {
  description = "Keypair name (pre-determined)"
}

variable "teams_webhook_url_ssm_name" {
  description = "SSM Parameter to which teams webhook url is set (pre-determined)"
}
