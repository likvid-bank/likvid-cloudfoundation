output "org_id" {
  value       = aws_organizations_organization.org.id
  description = "organiztion id"
}

output "org_root_id" {
  value       = local.org_root
  description = "id of the organization's root (AWS currently supports only a single root)"
}

output "parent_ou_id" {
  description = "id of the parent organizational unit"
  value       = aws_organizations_organizational_unit.parent.id
}

output "admin_ou_id" {
  value       = aws_organizations_organizational_unit.admin.id
  description = "id of the admin organizational unit"
}

output "landingzones_ou_id" {
  value       = aws_organizations_organizational_unit.landingzones.id
  description = "id of the landingzones organizational unit"
}

# output "automation_account_id" {
#   value = aws_organizations_account.automation.id
# }
#
# output "network_account_id" {
#   value = aws_organizations_account.network_management.id
# }
#
# output "meshstack_account_id" {
#   value = aws_organizations_account.meshstack.id
# }
