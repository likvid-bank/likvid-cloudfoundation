module "terraform_state" {
  count = var.terraform_state_storage != null ? 1 : 0

  source = "./terraform-state"
  location = var.terraform_state_storage.location
}

# Set permissions on the blob store
resource "azurerm_role_assignment" "tfstates_engineers" {
  count = var.terraform_state_storage != null ? 1 : 0

  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_group.platform_engineers.object_id
  scope                = module.terraform_state[0].container_id
}
