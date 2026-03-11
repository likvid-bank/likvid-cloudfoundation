output "owned_by_workspace" {
  description = "The meshstack workspace that owns the SKE platform resources"
  value       = data.meshstack_workspace.devops_platform.metadata.name
}

output "full_platform_identifier" {
  description = "The meshstack platform identifier for SKE namespaces"
  value       = meshstack_platform.ske.metadata.name
}

output "landing_zone_dev_identifier" {
  description = "The meshstack landing zone identifier for SKE dev namespaces"
  value       = meshstack_landingzone.dev.metadata.name
}

output "landing_zone_prod_identifier" {
  description = "The meshstack landing zone identifier for SKE prod namespaces"
  value       = meshstack_landingzone.prod.metadata.name
}
