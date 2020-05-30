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

data "aws_iam_policy_document" "assume_role_policy_ec2_ssm" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_ssm" {
  name = "${var.prefix_name}-${var.system_name}-${var.stage}-ec2-ssm"
  path = "/${var.prefix_name}-${var.system_name}-${var.stage}/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_ec2_ssm.json

  tags = {
    Name = "${var.prefix_name}-${var.system_name}-${var.stage}-ec2-ssm"
    Author = var.author
    Stage = var.stage
  }
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role = aws_iam_role.ec2_ssm.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.prefix_name}-${var.system_name}-${var.stage}-ssm"
  role = aws_iam_role.ec2_ssm.name
}

resource "aws_instance" "dev" {
  ami = data.aws_ami.ami_amzn2.image_id
  vpc_security_group_ids = [aws_security_group.public.id]
  subnet_id = aws_subnet.public.id
  key_name = var.key_name
  instance_type = var.dev_instance_type
  iam_instance_profile = aws_iam_instance_profile.ssm.id

  tags = {
    Name = "${var.prefix_name}-${var.system_name}-${var.stage}-dev"
    Author = var.author
    Stage = var.stage
  }
}
