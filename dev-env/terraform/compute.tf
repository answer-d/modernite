# AmazonLinux2 Latest AMI
data "aws_ami" "ami_amzn2" {
  most_recent = true
  owners = ["amazon"]

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
    values = ["amzn2-ami-hvm-*"]
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
    instance_type = "t2.micro"

    tags = {
        Name = "${var.prefix_name}-${var.system_name}-devinstance"
        Author = var.author
    }
}

output "public_ip" {
    description = "Public IP addresses assigned to the instances, if applicable"
    value = aws_instance.dev.public_ip
}

output "public_dns" {
    description = "Public DNS assigned to the instances, if applicable"
    value = aws_instance.dev.public_dns
}
