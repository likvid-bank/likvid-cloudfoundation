# set up an UAMI for the github actions pipeline to use

resource "azurerm_user_assigned_identity" "ghactions" {
  name                = "github-actions"
  location            = azurerm_resource_group.cicd.location
  resource_group_name = azurerm_resource_group.cicd.name
}

# see https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure#adding-the-federated-credentials-to-azure
resource "azurerm_federated_identity_credential" "ghactions" {  
  parent_id           = azurerm_user_assigned_identity.ghactions.id
  resource_group_name = azurerm_resource_group.cicd.name
  
  name                = "github-actions"
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"

  # see ../resources.github.tf for how the BB backplane sets up a "sandbox" environment for each deployment
  subject             = "repo:${github_repository.repository.full_name}:environment:${github_repository_environment.sandbox.environment}" 
}

# allow r/w terraform state
resource "azurerm_role_assignment" "ghaction_tfstate" {
  role_definition_name = "Storage Blob Data Owner"

  principal_id         = azurerm_user_assigned_identity.ghactions.principal_id
  scope                = azurerm_storage_container.tfstates.resource_manager_id
}

# output "documentation_uami_client_id" {
#   value = azurerm_user_assigned_identity.docs[0].client_id
# }