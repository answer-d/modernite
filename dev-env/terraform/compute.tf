# AmazonLinux2 Latest AMI
data "aws_ami" "ami_amzn2" {
  most_recent = true
  owners = ["self"]

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name = "name"
    values = ["yama-dev-env*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
  filter {
    name = "state"
    values = ["available"]
  }
}

resource "aws_instance" "dev" {
  ami = data.aws_ami.ami_amzn2.image_id
  vpc_security_group_ids = [aws_security_group.public.id]
  subnet_id = aws_subnet.public.id
  key_name = var.key_name
  instance_type = var.dev_instance_type

  tags = {
    Name = "${var.prefix_name}-${var.system_name}-${var.stage}-dev"
    Author = var.author
    Stage = var.stage
  }
}
