output "ssh_private_key" {
  value     = tls_private_key.building_block_implementation.private_key_openssh
  sensitive = true
}
