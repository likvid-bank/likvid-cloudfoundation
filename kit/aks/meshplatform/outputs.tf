output "replicator_service_principal" {
  description = "Replicator Service Principal."
  value       = module.meshplatform.replicator_service_principal
  sensitive   = true
}
