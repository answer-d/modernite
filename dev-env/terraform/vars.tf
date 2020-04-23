variable "prefix_name" {
    description = "String to be prepended to the resource name"
}

variable "system_name" {
    description = "String to be inserted to the resource name"
}

variable "author" {
    description = "The value of the tag `Author` to be assigned to all resources"
}

variable "vpc_id" {
    description = "Your vpc id (pre-determined)"
}

variable "public_subnet_cidr_block" {
    description = "Cidr block for public subnet"
}

variable "key_name" {
    description = "Keypair name"
}
