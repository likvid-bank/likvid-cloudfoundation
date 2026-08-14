output "platform_engineers_group_id" {
  description = "OCID of the platform engineers group"
  value       = oci_identity_group.platform_engineers.id
}

output "platform_engineers_group_name" {
  description = "Name of the platform engineers group"
  value       = oci_identity_group.platform_engineers.name
}

output "foundation_compartment_ocid" {
  description = "The OCID of the foundation compartment"
  value       = var.foundation_compartment_ocid
}

output "foundation_name" {
  description = "Name of the foundation"
  value       = var.foundation_name
}

output "tenancy_ocid" {
  description = "The OCID of the OCI tenancy"
  value       = var.tenancy_ocid
}
