output "documentation_md" {
  value  = <<EOF
Connection to the hub is the pre-requisite for getting access to th on-prem network.

The overall address space is `${join(",",var.address_space)}`.

Upon request, we will peer a VNet in your subscription with the hub.
EOF
}
