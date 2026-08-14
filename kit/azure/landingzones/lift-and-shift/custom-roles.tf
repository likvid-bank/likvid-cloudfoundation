# Custom RBAC role for VM operations
# This role allows users to restart and manage VM power states without delete permissions

resource "azurerm_role_definition" "vm_restart_operator" {
  name        = "VM Restart Operator"
  scope       = data.azurerm_subscription.current.id
  description = "Allows restarting and managing VM power states without delete permissions"

  permissions {
    actions = [
      # Read permissions for VMs
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Compute/virtualMachines/instanceView/read",

      # Power management actions
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/powerOff/action",
      "Microsoft.Compute/virtualMachines/restart/action",
      "Microsoft.Compute/virtualMachines/deallocate/action",

      # Read permissions for navigation
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Resources/subscriptions/read"
    ]

    not_actions = [
      # Explicitly deny delete operations
      "Microsoft.Compute/virtualMachines/delete",
      # Deny write operations that could modify VM configuration
      "Microsoft.Compute/virtualMachines/write"
    ]
  }

  assignable_scopes = [data.azurerm_subscription.current.id]
}
