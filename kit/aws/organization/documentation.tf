output "documentation_md" {
  value = <<EOF
# AWS Organization

The AWS Organization is owned by master account `${data.aws_organizations_organization.org.master_account_id}`.

This module sets up a basic organizational structure with administrative accounts

platform
  - landingzones

The administrative accounts are configured in separate kit modules.
EOF
}
