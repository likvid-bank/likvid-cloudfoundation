output "lift_and_shift_subscription_id" {
  value = data.azurerm_subscription.current.id
}

output "vm_restart_operator_role_id" {
  value       = azurerm_role_definition.vm_restart_operator.role_definition_id
  description = "The ID of the VM Restart Operator custom RBAC role"
}

output "vm_restart_operator_role_definition_resource_id" {
  value       = azurerm_role_definition.vm_restart_operator.role_definition_resource_id
  description = "The resource ID of the VM Restart Operator custom RBAC role for use in role assignments"
}
