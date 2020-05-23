resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix_name}-${var.system_name}-${var.stage}"
    Author = var.author
    Stage = var.stage
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${var.prefix_name}-${var.system_name}-${var.stage}-ig"
    Author = var.author
    Stage = var.stage
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.default.id
  cidr_block = var.public_subnet_cidr_block
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.prefix_name}-${var.system_name}-${var.stage}-public"
    Author = var.author
    Stage = var.stage
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  route {
    gateway_id = aws_internet_gateway.gw.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "${var.prefix_name}-${var.system_name}-${var.stage}-public-rt"
    Author = var.author
    Stage = var.stage
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "public" {
  vpc_id = aws_vpc.default.id
  name = "${var.prefix_name}-${var.system_name}-${var.stage}-public-sg"
  
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
    description = "allow ssh incoming from any network"
  }
  ingress {
    cidr_blocks = [aws_vpc.default.cidr_block]
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
    Name = "${var.prefix_name}-${var.system_name}-${var.stage}-public-sg"
    Author = var.author
    Stage = var.stage
  }
}
