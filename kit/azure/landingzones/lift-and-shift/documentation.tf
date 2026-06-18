output "documentation_md" {
  value = <<EOF
# Lift & Shift Landing Zone

A lift & shift landing zone is a pre-configured environment tailored for migrating existing workloads to the cloud.

Here, an existing subscription serves as the landing zone where the migrated workloads will be deployed using Azure resource groups.

- **Subscription Name**: ${var.lift_and_shift_subscription_name}
- **Subscription ID**: ${data.azurerm_subscription.current.id}

## Custom RBAC Roles

This landing zone includes custom RBAC roles for VM operations:

### VM Restart Operator

A custom role that allows users to manage VM power states (start, stop, restart, deallocate) without the ability to delete or modify VM configurations.

**Role ID**: ${azurerm_role_definition.vm_restart_operator.role_definition_id}

**Permissions included**:
- Read VM status and instance view
- Start, stop, restart, and deallocate VMs
- Navigate resource groups and subscriptions

**Permissions explicitly denied**:
- Delete VMs
- Modify VM configuration

This role is ideal for operators who need to manage VM availability without full administrative access.

EOF
}
