output "sandbox_compartment_id" {
  description = "OCID of the sandbox compartment"
  value       = oci_identity_compartment.sandbox.id
}

output "policy_id" {
  description = "OCID of the sandbox users policy"
  value       = oci_identity_policy.sandbox_users.id
}
