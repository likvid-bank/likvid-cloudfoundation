data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_compartment" "foundation" {
  id = var.foundation_compartment_ocid
}

resource "oci_identity_group" "platform_engineers" {
  compartment_id = var.tenancy_ocid
  name           = "${var.foundation_name}-${var.platform_engineers_group.name}"
  description    = "Platform engineering team with permissions to manage cloud foundation infrastructure"
}

resource "oci_identity_user_group_membership" "platform_engineers" {
  for_each = var.platform_engineers_group.members

  group_id = oci_identity_group.platform_engineers.id
  user_id  = each.value
}

resource "oci_identity_policy" "platform_engineers" {
  compartment_id = var.foundation_compartment_ocid
  name           = "${var.platform_engineers_group.name}-policy"
  description    = "Policy granting platform engineers permissions to manage cloud foundation"

  statements = [
    "Allow group ${oci_identity_group.platform_engineers.name} to manage all-resources in compartment ${data.oci_identity_compartment.foundation.name}",
    "Allow group ${oci_identity_group.platform_engineers.name} to manage compartments in compartment ${data.oci_identity_compartment.foundation.name}",
  ]
}

