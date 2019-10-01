data "terraform_remote_state" "pe" {
  backend = "remote"
  config = {
    organization = var.tf_pe_org
    workspaces = {
      name = var.tf_pe_workspace
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "allow_mysql" {
  name = "allow_mysql"
  description = "Allow mysql connections on port 3306"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["172.0.0.0/6"]
  }
}

resource "aws_instance" "dbserver" {
  ami               = var.ami_id
  instance_type     = var.instance_type
  availability_zone = "${var.aws_region}a"
  key_name          = data.terraform_remote_state.pe.outputs.key_name
  security_groups   = [
    "default",
    aws_security_group.allow_mysql.name,
    data.terraform_remote_state.pe.outputs.security_group
  ]

  tags = {
    Name        = "${var.name} - DB"
    TTL         = var.ttl
    Owner       = var.owner
    Description = var.description
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = data.terraform_remote_state.pe.outputs.PE_Master_SSH_key
  }
  provisioner "puppet" {
    server      = data.terraform_remote_state.pe.outputs.puppetmaster
    server_user = "ubuntu"
    open_source = false
    use_sudo    = true
    extension_requests = {
      pp_role = "dbserver"
    }
  }

  provisioner "remote-exec" {
    connection {
      host        = data.terraform_remote_state.pe.outputs.puppetmaster
      type        = "ssh"
      user        = "ubuntu"
      private_key = data.terraform_remote_state.pe.outputs.PE_Master_SSH_key
    }
    when   = "destroy"
    inline = [
      "sudo puppet node purge ${self.private_dns}"
    ]
  }
}

resource "aws_instance" "webserver" {
  ami               = var.ami_id
  instance_type     = var.instance_type
  availability_zone = "${var.aws_region}a"
  key_name          = data.terraform_remote_state.pe.outputs.key_name
  security_groups   = ["default", data.terraform_remote_state.pe.outputs.security_group]
  depends_on        = [aws_instance.dbserver]

  tags = {
    Name        = "${var.name} - Web"
    TTL         = var.ttl
    Owner       = var.owner
    Description = var.description
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = data.terraform_remote_state.pe.outputs.PE_Master_SSH_key
  }

  provisioner "puppet" {
    server      = data.terraform_remote_state.pe.outputs.puppetmaster
    server_user = "ubuntu"
    open_source = false
    use_sudo    = true
    extension_requests = {
      pp_role        = "webserver"
      pp_application = aws_instance.dbserver.private_dns
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm /var/www/html/index.html"
    ]
  }

  provisioner "remote-exec" {
    connection {
      host        = data.terraform_remote_state.pe.outputs.puppetmaster
      type        = "ssh"
      user        = "ubuntu"
      private_key = data.terraform_remote_state.pe.outputs.PE_Master_SSH_key
    }
    when   = "destroy"
    inline = [
      "sudo puppet node purge ${self.private_dns}"
    ]
  }
}

