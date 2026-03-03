output "replicator_token" {
  description = "Service account token for the meshStack replicator"
  value       = module.meshplatform.replicator_token
  sensitive   = true
}

output "metering_token" {
  description = "Service account token for the meshStack metering agent"
  value       = module.meshplatform.metering_token
  sensitive   = true
}
