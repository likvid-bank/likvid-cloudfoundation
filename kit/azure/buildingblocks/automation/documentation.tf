output "documentation_md" {
  value = <<EOF

# 🏗️ Building Blocks Automation Infrastructure

This module automates the deployment of building blocks within Azure. It utilizes service principles for automation. The states of these resources are maintained in a designated storage account.

## 🛠️ Service Principal 

- **NAME**: `${azuread_service_principal.buildingblock.display_name}`
- **ID**: `${azuread_service_principal.buildingblock.id}`
- **Client ID**: `${azuread_service_principal.buildingblock.client_id}`

## 🗃️ Storage Account

- **RESOURCE GROUP**: `${azurerm_resource_group.tfstates.name}`  
- **Name**: `${azurerm_storage_account.tfstates.name}`
- **Container Name**: `${azurerm_storage_container.tfstates.name}`

EOF
}
