variable "pe_version" {
  description = "Version of PE to install"
  default     = "2019.0.2"
}

variable "pe_dist" {
  description = "Distribution for PE install"
  default     = "ubuntu"
}

variable "pe_release" {
  description = "Operating system release for PE install"
  default     = "16.04"
}

variable "pe_arch" {
  description = "Architecture for PE install"
  default     = "amd64"
}

variable "admin_password" {
  description = "PE Console Admin password"
  default     = "puppetlabs"
}
