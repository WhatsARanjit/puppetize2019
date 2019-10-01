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

resource "aws_instance" "dbserver" {
  ami               = var.ami_id
  instance_type     = var.instance_type
  availability_zone = "${var.aws_region}a"
  key_name          = data.terraform_remote_state.pe.outputs.key_name
  security_groups   = ["default", data.terraform_remote_state.pe.outputs.security_group]

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
      pp_application = aws_instance.dbserver.public_dns
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
      "puppet node purge ${self.public_dns}"
    ]
  }
}

