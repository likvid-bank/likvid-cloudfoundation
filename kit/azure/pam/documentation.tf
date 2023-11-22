output "documentation_md" {
  value = <<EOF

# Privileged Access Management

The following groups are used for managing privileged access to the cloud foundation.

|Group|Member|Function|Object ID|
|-|-|-|-|
| `${var.platform_engineer.group.display_name}` | ${join("<br>", formatlist("%s", var.platform_engineer.group.member))} | group is used to grant privileged access to members of the cloud foundation team. | `${var.platform_engineer.group.object_id}` |
| `${var.security_admin.group.display_name}` | ${join("<br>", formatlist("%s", var.security_admin_members[*].email))} | Responsible for administrate ensuring compliance and security across cloud resources. | `${var.security_admin.group.object_id}` |
| `${var.security_auditor.group.display_name}` | ${join("<br>", formatlist("%s", var.security_auditor_members[*].email))} | Responsible for ensuring compliance and security across cloud resources. | `${var.security_auditor.group.object_id}` |
| `${var.billing_admin.group.display_name}` | ${join("<br>", formatlist("%s", var.billing_admin_members[*].email))} | Manage financial aspects of cloud usage and allocate costs to various teams or projects. | `${var.billing_admin.group.object_id}` |
| `${var.billing_reader.group.display_name}` | ${join("<br>", formatlist("%s", var.billing_reader_members[*].email))} | Can read Manage financial aspects of cloud usage and allocate costs to various teams or projects. | `${var.billing_reader.group.object_id}` |

EOF
}
