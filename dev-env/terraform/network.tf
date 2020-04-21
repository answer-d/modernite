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
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.prefix_name}-${var.system_name}-public"
        Author = var.author
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = var.vpc_id
    tags = {
        Name = "${var.prefix_name}-${var.system_name}-public-rt"
        Author = var.author
    }
}

resource "aws_route" "public_route_ig" {
    gateway_id = aws_internet_gateway.gw.id
    route_table_id = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_rt_assoc" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}
