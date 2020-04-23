data "aws_vpc" "default" {
    id = var.vpc_id
}

resource "aws_internet_gateway" "gw" {
    vpc_id = data.aws_vpc.default.id

    tags = {
        Name = "${var.prefix_name}-${var.system_name}-ig"
        Author = var.author
    }
}

resource "aws_subnet" "public" {
    vpc_id = data.aws_vpc.default.id
    cidr_block = var.public_subnet_cidr_block
    map_public_ip_on_launch = true
    
    tags = {
        Name = "${var.prefix_name}-${var.system_name}-public"
        Author = var.author
    }
}

resource "aws_route_table" "public" {
    vpc_id = data.aws_vpc.default.id

    route {
        gateway_id = aws_internet_gateway.gw.id
        cidr_block = "0.0.0.0/0"
    }

    tags = {
        Name = "${var.prefix_name}-${var.system_name}-public-rt"
        Author = var.author
    }
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "public" {
    vpc_id = data.aws_vpc.default.id
    name = "${var.prefix_name}-${var.system_name}-public-sg"
    
    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 22
        to_port = 22
        protocol = "tcp"
        description = "allow ssh incoming from any network"
    }
    ingress {
        cidr_blocks = [data.aws_vpc.default.cidr_block]
        from_port = -1
        to_port = -1
        protocol = "icmp"
        description = "allow icmp incoming from vpc network"
    }

    egress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 0
        to_port = 0
        protocol = "-1"
        description = "allow all outgoing"
    }

    tags = {
        Name = "${var.prefix_name}-${var.system_name}-public-sg"
        Author = var.author
    }
}
