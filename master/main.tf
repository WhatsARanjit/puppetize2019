provider "aws" {
  region = "${var.aws_region}"
}

resource "tls_private_key" "pemaster" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.owner}-${var.key_name}"
  public_key = "${tls_private_key.pemaster.public_key_openssh}"
}

data "template_file" "peconf" {
  template = "${file("${path.module}/templates/pe.conf.tpl")}"
  vars = {
    admin_password = "${var.admin_password}"
  }
}

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
  description = "Allow ssh connections on port 22"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_https" {
  name = "allow_https"
  description = "Allow ssh connections on port 443 and 8140"
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8140
    to_port     = 8140
    protocol    = "tcp"
    cidr_blocks = ["172.0.0.0/6"]
  }
}

data "aws_ami" "latest-ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

resource "aws_instance" "pe-ubuntu" {
  ami               = "${data.aws_ami.latest-ubuntu.id}"
  instance_type     = "${var.instance_type}"
  availability_zone = "${var.aws_region}a"
  key_name          = "${aws_key_pair.generated_key.key_name}"
  security_groups   = [
    "default",
    "allow_https",
    "${aws_security_group.allow_ssh.name}"
  ]

  tags {
    Name        = "${var.name}"
    TTL         = "${var.ttl}"
    Owner       = "${var.owner}"
    Description = "${var.description}"
  }

  connection {
    host        = "${self.public_ip}"
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${tls_private_key.pemaster.private_key_pem}"
  }

  provisioner "file" {
    content     = "${data.template_file.peconf.rendered}"
    destination = "/tmp/pe.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sed -i 's/PUBLICDNS/${self.public_dns}/' /tmp/pe.conf"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "wget --quiet --content-disposition 'https://pm.puppet.com/cgi-bin/download.cgi?dist=${var.pe_dist}&rel=${var.pe_release}&arch=${var.pe_arch}&ver=${var.pe_version}'",
      "tar zxpf puppet-enterprise-${var.pe_version}-${var.pe_dist}-${var.pe_release}-${var.pe_arch}.tar.gz"
    ]
  }

  provisioner "file" {
    source      = "files/"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "/bin/bash /tmp/pe_install.sh"
    ]
  }
}
