# must set environment variable above
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY

provider "aws" {
    region = "ap-northeast-1"
}

resource "aws_internet_gateway" "gw" {
    vpc_id = var.vpc_id
    tags = {
        Name = "${var.prefix_name}-${var.system_name}-ig"
        Author = var.author
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = var.vpc_id
    cidr_block = var.public_subnet_cide_block
    tags = {
        Name = "${var.prefix_name}-${var.system_name}-public"
        Author = var.author
    }
}
