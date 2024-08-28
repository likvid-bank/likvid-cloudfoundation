output "documentation_md" {
  value = <<EOF
# AWS Organization

The AWS Organization is owned by master account `${aws_organizations_organization.org.master_account_id}`.

This module sets up a basic organizational structure with administrative accounts

platform
  - admin
    - Automation Account `${aws_organizations_account.automation.id}` hosting cloud foundation automation
    - Network Management Account `${aws_organizations_account.network_management.id}` hosting networking
    - meshStack Account `${aws_organizations_account.meshstack.id}` hosting meshPlatform integration into meshStack
  - landingzones

The administrative accounts are configured in separate kit modules.
EOF
}
