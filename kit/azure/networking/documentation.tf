output "documentation_md" {
  value  = <<EOF
Connection to the hub is the pre-requisite for getting access to th on-prem network.

The hub itself has the following address space `${join(",",var.address_space)}`.

Upon request, we will peer a VNet in your subscription with the hub.

We currently have assigned

|Application|Range|
|Glaskubel|10.1.0.0/24|

Next free entry: 10.1.0.1/24
EOF
}
