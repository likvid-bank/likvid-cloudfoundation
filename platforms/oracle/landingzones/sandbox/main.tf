resource "oci_identity_compartment" "sandbox" {
  compartment_id = var.parent_compartment_id
  name           = "${var.foundation}-sandbox"
  description    = "Sandbox environment for experimentation and learning"
}

resource "oci_identity_policy" "sandbox_users" {
  compartment_id = oci_identity_compartment.sandbox.id
  name           = "${var.foundation}-sandbox-users-policy"
  description    = "Policy for sandbox users with limited permissions"

  statements = [
    "Allow group ${var.sandbox_users_group} to manage instance-family in compartment ${oci_identity_compartment.sandbox.name}",
    "Allow group ${var.sandbox_users_group} to manage virtual-network-family in compartment ${oci_identity_compartment.sandbox.name}",
    "Allow group ${var.sandbox_users_group} to manage volume-family in compartment ${oci_identity_compartment.sandbox.name}",
    "Allow group ${var.sandbox_users_group} to manage object-family in compartment ${oci_identity_compartment.sandbox.name}",
    "Allow group ${var.sandbox_users_group} to read all-resources in compartment ${oci_identity_compartment.sandbox.name}",
  ]
}
