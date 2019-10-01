output "puppetmaster" {
  value = "${aws_instance.pe-ubuntu.public_dns}"
}

output "key_name" {
  value = "${aws_key_pair.generated_key.key_name}"
}

output "security_group" {
  value = "${aws_security_group.allow_ssh.name}"
}

output "PE_Master_SSH" {
  value = "ssh ubuntu@${aws_instance.pe-ubuntu.public_dns}"
}

output "PE_Master_SSH_key" {
  value = "${tls_private_key.pemaster.private_key_pem}"
}
