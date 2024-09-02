output "documentation_md" {
  value = <<EOF
# AWS Organization

The AWS Organization is owned by master account `${data.aws_organizations_organization.org.master_account_id}`.

This module sets up a basic organizational structure with administrative accounts

platform
  - ${aws_organizations_organizational_unit.landingzones.name}
  - ${aws_organizations_organizational_unit.management.name}
  - likvid-m25-platform

The administrative accounts are configured in separate kit modules.
EOF
}
