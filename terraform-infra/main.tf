provider "aws" {
  region                  = var.aws_region
  profile                 = var.aws_creds_profile
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
  instance_type = var.aws_ec2_instance_type
  key_name      = aws_key_pair.ec2_keys.key_name

  tags = {
    Name = "jenkins-server"
  }

  # Install Jenkins according to https://www.digitalocean.com/community/tutorials/how-to-install-jenkins-on-ubuntu-20-04
  # Install Terraform to ensure we can run terraform validate on jenkins
  # Install ansible and ensure community.general.terraform https://docs.ansible.com/ansible/latest/collections/community/general/terraform_module.html
  # Install the plugins under the jenkins user, otherwise the community.general.terraform won't be found
  user_data = <<EOF
#!/bin/bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install default-jre terraform jenkins -y
sudo systemctl start jenkins
sudo apt install ansible -y
sudo -H -u jenkins bash -c "ansible-galaxy collection install community.general"
EOF
}

resource "aws_instance" "targets" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.aws_ec2_instance_type
  key_name      = aws_key_pair.ec2_keys.key_name

  tags = {
    Name = "target-server-${count.index}--${count.index % 2 == 0 ? "prod" : "dev"}"
  }
}

