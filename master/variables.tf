variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "key_name" {
  description = "Generated SSH key pair"
  default     = "pe-master-demo"
}

variable "instance_type" {
  description = "type of EC2 instance to provision."
  default     = "m1.large"
}

variable "name" {
  description = "name to pass to Name tag"
  default     = "PE Master"
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
  default     = "PE Master Provisioned by Terraform"
}
