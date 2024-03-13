data "azurerm_subscription" "current" {
}

# set up roles that we will need at the top of the management group hierarchy

#
# Access Role
#
resource "azurerm_role_definition" "buildingblock_access_spoke" {
  name              = "buildingblock-${var.name}-access"
  description       = "Allow self-assignment of a deployment role on an application team's subscription that in turn enables provisioning of building block resources."
  scope             = var.scope
  assignable_scopes = [var.scope]

  permissions {
    actions = [
      "Microsoft.Authorization/roleAssignments/*"
    ]
  }
}

resource "azurerm_role_assignment" "buildingblock_access_spoke" {
  for_each = var.principal_ids

  role_definition_id = azurerm_role_definition.buildingblock_access_spoke.role_definition_resource_id
  description        = azurerm_role_definition.buildingblock_access_spoke.description
  principal_id       = each.key
  scope              = var.scope

  condition_version = "2.0"

  # what this does: if the request is a roleAssignment write or a delete, check that it only contains the expected deploy role
  # this ensures that we can only deploy that role
  condition = <<-EOT
(
  !(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})
  AND
  !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
)
OR
(
  @Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${azurerm_role_definition.buildingblock_deploy_spoke.role_definition_id}}
  AND
  @Request[Microsoft.Authorization/roleAssignments:PrincipalId] ForAnyOfAnyValues:GuidEquals {${each.key}}
)
EOT
}

#
# Deploy Roles
#

# note: this role will be assigned using the access role above
resource "azurerm_role_definition" "buildingblock_deploy_spoke" {
  name        = "buildingblock-${var.name}-deploy-spoke"
  description = "Enables deployment of the ${var.name} building block spoke to subscriptions."
  scope       = data.azurerm_subscription.current.id # assume we are running in the spoke subscription anyway

  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/*",
      "Microsoft.Network/virtualNetworks/read",
      "Microsoft.Network/virtualNetworks/write",
      "Microsoft.Network/virtualNetworks/delete",
      "Microsoft.Network/virtualNetworks/subnets/*",
      "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/*"
    ]
  }
}

resource "azurerm_role_definition" "buildingblock_deploy_hub" {
  name        = "buildingblock-${var.name}-deploy-hub"
  description = "Enables deployment of the ${var.name} building block to the hub"
  scope       = data.azurerm_subscription.current.id # assume we are running in the spoke subscription anyway

  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/*",
      "Microsoft.Network/virtualNetworks/read",
      "Microsoft.Network/virtualNetworks/write",
      "Microsoft.Network/virtualNetworks/delete",
      "Microsoft.Network/virtualNetworks/subnets/*",
      "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/*"
    ]
  }
}


resource "azurerm_role_assignment" "buildingblock_deploy_spoke" {
  for_each = var.principal_ids

  role_definition_id = azurerm_role_definition.buildingblock_deploy_hub.role_definition_resource_id
  description        = azurerm_role_definition.buildingblock_deploy_hub.description
  principal_id       = each.key
  scope              = data.azurerm_subscription.current.id # assume we are running in the spoke subscription anyway
}