output "dns_zone_id" {
  description = "STACKIT DNS zone ID"
  value       = stackit_dns_zone.idp.zone_id
}

output "stackit_project_id" {
  description = "STACKIT project ID"
  value       = stackit_dns_zone.idp.project_id
}
