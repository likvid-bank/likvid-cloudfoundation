output "replicator_service_principal" {
  description = "Replicator Service Principal."
  value       = module.meshplatform.replicator_service_principal
  sensitive   = true
}

output "replicator_service_principal_password" {
  description = "Password for Replicator Service Principal."
  value       = module.meshplatform.replicator_service_principal_password
  sensitive   = true
}
