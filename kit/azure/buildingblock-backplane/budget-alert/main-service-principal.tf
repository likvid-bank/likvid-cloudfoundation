variable "provider_tf_config_path" {
  type = string
}
variable "deployment_scope" {
  type        = string
  description = "The scope where this service principal have access on. It is recommended to use the meshcloud's management group, so the buildingblock can be re-used within any projects"
  validation {
    condition     = can(regex("/providers/Microsoft.Management/managementGroups/[^/]+", var.deployment_scope))
    error_message = "Should be in the format of '/providers/Microsoft.Management/managementGroups/XXXX"
  }
}

variable "container_id" {
  type        = string
  description = "Id of the tfstate's container"
}

variable "sta_rg_id" {
  type        = string
  description = "Id of the storage account's resource group"
}

//---------------------------------------------------------------------------
// Create New application in Microsoft Entra ID
//---------------------------------------------------------------------------
resource "azuread_application" "building_blocks" {
  display_name = "likvid-buildingblocks-budget-alert"

  feature_tags {
    enterprise = true
  }
  web {
    implicit_grant {
      access_token_issuance_enabled = false
    }
  }

  lifecycle {
    ignore_changes = [
      app_role
    ]
  }

}

//---------------------------------------------------------------------------
// Create new client secret and associate it with building_blocks_application application
//---------------------------------------------------------------------------
resource "time_rotating" "building_blocks_secret_rotation" {
  rotation_days = 365
}
resource "azuread_application_password" "building_blocks_application_pw" {
  application_id = azuread_application.building_blocks.id

  rotate_when_changed = {
    rotation = time_rotating.building_blocks_secret_rotation.id
  }
}

//---------------------------------------------------------------------------
// Create new Enterprise Application and associate it with building_blocks_application application
//---------------------------------------------------------------------------
resource "azuread_service_principal" "building_blocks_spn" {
  client_id = azuread_application.building_blocks.client_id


  feature_tags {
    enterprise = true
  }
}


//---------------------------------------------------------------------------
// Assign the created ARM role to the Enterprise application
//---------------------------------------------------------------------------

resource "azurerm_role_assignment" "building_blocks_backend" {
  scope = var.sta_rg_id
  #role_definition_id =  "/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.building_blocks_spn.id
}
resource "azurerm_role_assignment" "backend_storage_read" {
  scope                = var.sta_rg_id
  role_definition_name = "Storage Account Key Operator Service Role"
  principal_id         = azuread_service_principal.building_blocks_spn.id
}

resource "azurerm_role_definition" "role_budget_rg" {
  name        = "deploy_likvid-budget_alert_bb"
  scope       = var.deployment_scope
  description = "Allows for creating and deleting resource groups, action groups, and budget alerts"

  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/*",
      "Microsoft.Insights/actionGroups/*",
      "Microsoft.Consumption/budgets/*",
      # Permission we need to activate/register required Resource Providers
      "*/register/action"
    ]
    not_actions = []
  }

  assignable_scopes = [
    var.deployment_scope
  ]
}

resource "azurerm_role_assignment" "custom_contributor" {
  # this permission is to create and assign budget alert + action group resource
  # can be more fine graned
  scope                = var.deployment_scope
  role_definition_name = azurerm_role_definition.role_budget_rg.name
  #role_definition_id = "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
  principal_id = azuread_service_principal.building_blocks_spn.id
}


output "provider_tf" {

  description = "Generates a config.tf that can be dropped into meshStack's BuildingBlockDefinition as an encrypted file input to configure this building block."
  sensitive   = true
  value       = <<EOF
  terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=3.86.0"
    }
  }
}
  provider "azurerm" {
    features  {}
    client_id       = "${azuread_application.building_blocks.client_id}"
    client_secret   = "${azuread_application_password.building_blocks_application_pw.value}"
    tenant_id       = "${var.tenant_id}"
    subscription_id = var.subscription_id
  }
EOF
}


resource "local_file" "provider" {
  count    = var.generate_local_files
  filename = var.provider_tf_config_path
  content  = <<-EOT
  terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=3.86.0"
    }
  }
}
  provider "azurerm" {
    features  {}
    client_id       = "${azuread_application.building_blocks.client_id}"
    client_secret   = "${azuread_application_password.building_blocks_application_pw.value}"
    tenant_id       = "${var.tenant_id}"
    subscription_id = var.subscription_id
  }
EOT
}
