resource "oci_identity_compartment" "cloud_native" {
  compartment_id = var.parent_compartment_id
  name           = "${var.foundation}-cloud-native"
  description    = "Cloud-native landing zone for modern application workloads"
}

resource "oci_identity_compartment" "dev" {
  compartment_id = oci_identity_compartment.cloud_native.id
  name           = "dev"
  description    = "Development environment for cloud-native workloads"
}

resource "oci_identity_compartment" "prod" {
  compartment_id = oci_identity_compartment.cloud_native.id
  name           = "prod"
  description    = "Production environment for cloud-native workloads"
}

resource "oci_identity_policy" "cloud_native_users" {
  compartment_id = oci_identity_compartment.cloud_native.id
  name           = "${var.foundation}-cloud-native-users-policy"
  description    = "Policy for cloud-native landing zone users"

  statements = [
    "Allow group ${var.cloud_native_users_group} to manage all-resources in compartment ${oci_identity_compartment.dev.name}",
    "Allow group ${var.cloud_native_users_group} to read all-resources in compartment ${oci_identity_compartment.prod.name}",
    "Allow group ${var.cloud_native_admins_group} to manage all-resources in compartment ${oci_identity_compartment.cloud_native.name}",
  ]
}
