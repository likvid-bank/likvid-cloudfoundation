data "azurerm_subscription" "current" {}

#
# set up an UAMI for the github actions pipeline to use
#

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

#
# allow developers access to the terraform state
#

# note: this group is managed via meshStack and provided as part of the sandbox landing zone
data "azuread_group" "project_admins" {
  display_name = "${var.workspace_identifier}.${var.project_identifier}-admin"  
}

resource "azurerm_role_assignment" "project_admins" {
  role_definition_name = "Storage Blob Data Owner"

  principal_id         = data.azuread_group.project_admins.object_id
  scope                = azurerm_storage_container.tfstates.resource_manager_id
}

#
# add pipeline file to repo
#

locals {
  commit_message = "Set up CI/CD workflows"
  commit_author  = "DevOps Toolchain Team"
  commit_email   = "devopstoolchain@likvid-bank.com"
}

resource "github_repository_file" "deploy_yml" {
  repository          = github_repository.repository.name
  commit_message      = local.commit_message
  commit_author       = local.commit_author
  commit_email        = local.commit_email

  file                = ".github/workflows/deploy.yml"
  content             = <<-EOT
name: Deploy

on:
  push:
    branches:
      - "${github_repository_environment_deployment_policy.sandbox.branch_pattern}"

# Configure terraform to use UAMI set up by the starterkit building block using workload identity federation.
# We use enviornment variables here because this allows you to use the same provider.tf and backend config.tf when
# working with terraform locally and authenticating via Azure CLI
# See https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#argument-reference
env:
  ARM_USE_OIDC: "true"
  ARM_CLIENT_ID: "${azurerm_user_assigned_identity.ghactions.client_id}"

jobs:
  deploy:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    permissions:
      id-token: write
      contents: write
    environment:
      name: ${github_repository_environment_deployment_policy.sandbox.environment}
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v2
        with:
            terraform_version: "1.5.5"      
      - run: terraform init
      - run: terraform plan

EOT
}

resource "github_repository_file" "provider_tf" {
  repository          = github_repository.repository.name
  commit_message      = local.commit_message
  commit_author       = local.commit_author
  commit_email        = local.commit_email

  file                = "provider.tf"
  content             = <<-EOT
provider "azurerm" {
  features {}
  skip_provider_registration = false
  tenant_id                  = "${data.azurerm_subscription.current.tenant_id}"
  subscription_id            = "${data.azurerm_subscription.current.subscription_id}"
  storage_use_azuread        = true
}
EOT
}

resource "github_repository_file" "backend_tf" {
  repository          = github_repository.repository.name
  commit_message      = local.commit_message
  commit_author       = local.commit_author
  commit_email        = local.commit_email

  file                = "backend.tf"
  content             = <<-EOT
terraform {
  backend "azurerm" {
    use_azuread_auth      = true
    tenant_id             = "${data.azurerm_subscription.current.tenant_id}"
    subscription_id       = "${data.azurerm_subscription.current.subscription_id}"  
    resource_group_name   = "${azurerm_resource_group.cicd.name}"
    storage_account_name  = "${azurerm_storage_account.tfstates.name}"
    container_name        = "${azurerm_storage_container.tfstates.name}"
    key                   = "starterkit.tfstate"
  }
}
EOT
}
