output "org_id" {
  value       = data.aws_organizations_organization.org.id
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

output "landingzones_ou_id" {
  value       = aws_organizations_organizational_unit.landingzones.id
  description = "id of the landingzones organizational unit"
}

output "landingzones_ou_arn" {
  value       = aws_organizations_organizational_unit.landingzones.arn
  description = "arn of the landingzones organizational unit"
}

output "management_account_id" {
  value       = aws_organizations_account.management.id
  description = "id of the management account"
}

output "networking_account_id" {
  value       = aws_organizations_account.networking.id
  description = "id of the networking account"
}

output "automation_account_id" {
  value       = aws_organizations_account.automation.id
  description = "id of the automation account"
}

output "meshstack_account_id" {
  value       = aws_organizations_account.meshstack.id
  description = "id of the meshstack account"
}
