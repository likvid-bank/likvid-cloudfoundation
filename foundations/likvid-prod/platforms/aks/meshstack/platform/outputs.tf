output "owned_by_workspace" {
  description = "The meshstack workspace that owns the AKS platform resources"
  value       = var.meshstack.owning_workspace_identifier
}

output "platform_ref" {
  description = "Reference to the meshPlatform for AKS namespaces."
  value       = meshstack_platform.aks.ref
}
