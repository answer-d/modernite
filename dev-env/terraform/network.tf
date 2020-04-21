resource "aws_internet_gateway" "gw" {
    vpc_id = var.vpc_id
    tags = {
        Name = "${var.prefix_name}-${var.system_name}-ig"
        Author = var.author
    }
}

resource "aws_subnet" "public" {
    vpc_id = var.vpc_id
    cidr_block = var.public_subnet_cidr_block
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.prefix_name}-${var.system_name}-public"
        Author = var.author
    }
}

resource "aws_route_table" "public" {
    vpc_id = var.vpc_id
    tags = {
        Name = "${var.prefix_name}-${var.system_name}-public-rt"
        Author = var.author
    }
}

resource "aws_route" "public_ig" {
    gateway_id = aws_internet_gateway.gw.id
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "public" {
    vpc_id = var.vpc_id
    name = "${var.prefix_name}-${var.system_name}-public-sg"
    tags = {
        Name = "${var.prefix_name}-${var.system_name}-public-sg"

    }
}

# todo: modify this vulnerable rule!
resource "aws_security_group_rule" "in_ssh" {
    security_group_id = aws_security_group.public.id
    type              = "ingress"
    cidr_blocks       = ["0.0.0.0/0"]
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
}
