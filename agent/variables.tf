variable "tf_pe_org" {
  description = "Name of Terraform Organization where PE Master lives"
  default     = "puppetizepdx2019"
}

variable "tf_pe_workspace" {
  description = "Name of Terraform workspace where PE Master lives"
  default     = "puppetmaster"
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "ID of the AMI to provision. Default is Ubuntu 16.04 Base Image"
  default     = "ami-021d9d94f93a07a43"
}

variable "instance_type" {
  description = "type of EC2 instance to provision."
  default     = "t2.micro"
}

variable "name" {
  description = "name to pass to Name tag"
  default     = "PE Agent"
}

variable "owner" {
  description = "Name to pass to the Owner tag"
  default     = "Ranjit"
}

variable "ttl" {
  description = "Hours until instances are reaped by N.E.P.T.R"
  default     = "72"
}

variable "description" {
  description = "So meta"
  default     = "PE Agent Provisioned by Terraform"
}

