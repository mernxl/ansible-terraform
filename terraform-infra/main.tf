terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=3.66.0"
    }
  }
}

provider "aws" {
  region                  = "eu-north-1"
  shared_credentials_file = "~/.aws/credentials"
}

locals {
  key_name = "ec2-terra-ansi"
}

resource "tls_private_key" "ec2_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
  provisioner "local-exec" {
    command = "echo '${tls_private_key.ec2_private_key.private_key_pem}' > ../${local.key_name}.pem"
  }
}

resource "null_resource" "key-perm" {
  depends_on = [tls_private_key.ec2_private_key]

  provisioner "local-exec" {
    command = "chmod 400 ../${local.key_name}.pem"
  }
}

resource "aws_key_pair" "ec2_keys" {
  key_name   = local.key_name
  public_key = tls_private_key.ec2_private_key.public_key_openssh
}

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.ec2_keys.key_name

  tags = {
    Name = "jenkins-server"
  }

  # Install Jenkins according to https://www.digitalocean.com/community/tutorials/how-to-install-jenkins-on-ubuntu-20-04
  user_data = <<EOF
#!/bin/bash
sudo wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install default-jre -y
sudo apt install jenkins -y
sudo systemctl start jenkins
EOF
}

