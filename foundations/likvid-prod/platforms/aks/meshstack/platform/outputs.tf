output "owned_by_workspace" {
  description = "The meshstack workspace that owns the AKS platform resources"
  value       = var.meshstack.owning_workspace_identifier
}

output "full_platform_identifier" {
  description = "The meshstack platform identifier for AKS namespaces"
  value       = "${meshstack_platform.aks.metadata.name}.${meshstack_platform.aks.spec.location_ref.name}"
}
