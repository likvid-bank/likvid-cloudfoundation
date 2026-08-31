output "cloud_native_compartment_id" {
  description = "OCID of the cloud-native root compartment"
  value       = oci_identity_compartment.cloud_native.id
}

output "dev_compartment_id" {
  description = "OCID of the development compartment"
  value       = oci_identity_compartment.dev.id
}

output "prod_compartment_id" {
  description = "OCID of the production compartment"
  value       = oci_identity_compartment.prod.id
}

output "policy_id" {
  description = "OCID of the cloud-native users policy"
  value       = oci_identity_policy.cloud_native_users.id
}
