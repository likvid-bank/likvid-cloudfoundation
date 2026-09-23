output "audit_retention_days" {
  description = "Configured audit log retention period in days"
  value       = oci_audit_configuration.audit_retention.retention_period_days
}

output "host_scan_recipe_id" {
  description = "OCID of the host vulnerability scanning recipe"
  value       = oci_vulnerability_scanning_host_scan_recipe.default.id
}

output "container_scan_recipe_id" {
  description = "OCID of the container vulnerability scanning recipe"
  value       = oci_vulnerability_scanning_container_scan_recipe.default.id
}
