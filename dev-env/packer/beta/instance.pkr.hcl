source "amazon-ebs" "default" {
  ami_name = "yama-dev-env-{{ timestamp }}"
  instance_type = "t2.micro"

  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
      root-device-type = "ebs"
    }
    owners = ["099720109477"]
    most_recent = true
  }

  communicator = "ssh"
  ssh_username = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.default",
  ]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
    ]
  }

  provisioner "ansible-local" {
    playbook_file = "setup.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "tests/main.yml"
  }
}
