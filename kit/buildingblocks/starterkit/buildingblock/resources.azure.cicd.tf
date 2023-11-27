resource "azurerm_resource_group" "cicd" {
  name     = "ci-cd"
  location = var.location
}

#
# Terraform State Storage
#

resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_storage_account" "tfstates" {
  name                      = "tfstates${random_string.resource_code.result}"
  resource_group_name       = azurerm_resource_group.cicd.name
  location                  = azurerm_resource_group.cicd.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  shared_access_key_enabled = false
}

resource "azurerm_storage_container" "tfstates" {
  name                  = "tfstates"
  storage_account_name  = azurerm_storage_account.tfstates.name
  container_access_type = "blob"
}

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

  name     = "github-actions"
  audience = ["api://AzureADTokenExchange"]
  issuer   = "https://token.actions.githubusercontent.com"

  # see ../resources.github.tf for how the BB backplane sets up a "sandbox" environment for each deployment
  subject = "repo:${github_repository.repository.full_name}:environment:${github_repository_environment.sandbox.environment}"
}

resource "azurerm_role_assignment" "ghaction_tfstate" {
  role_definition_name = "Storage Blob Data Owner"
  description          = "allows the ${azurerm_user_assigned_identity.ghactions.name} UAMI to read/write terraform state"

  principal_id = azurerm_user_assigned_identity.ghactions.principal_id
  scope        = azurerm_storage_container.tfstates.resource_manager_id
}


#
# add pipeline file to repo
#

locals {
  commit_author  = "DevOps Toolchain Team"
  commit_email   = "devopstoolchain@likvid-bank.com"
}

resource "github_repository_file" "deploy_yml" {
  repository     = github_repository.repository.name
  commit_message = "Configuring a deploy pipeline"
  commit_author  = local.commit_author
  commit_email   = local.commit_email

  file    = ".github/workflows/deploy.yml"
  content = <<-EOT
name: Deploy

on:
  push:
    branches:
      - "${github_repository_environment_deployment_policy.sandbox.branch_pattern}"

# Configure terraform to use UAMI set up by the starterkit building block using workload identity federation.
# We use enviornment variables here because this allows you to use the same provider.tf and backend.tf files when
# checking out the repo locally for working with terraform, falling back to Azure CLI authentication.
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
      - run: terraform apply -auto-approve

EOT
}

resource "github_repository_file" "provider_tf" {
  repository     = github_repository.repository.name
  commit_message = "Configuring azurerm provider to deploy to your subscription"
  commit_author  = local.commit_author
  commit_email   = local.commit_email

  file    = "provider.tf"
  content = <<-EOT
provider "azurerm" {
  features {}
  skip_provider_registration = false
  tenant_id                  = "${data.azurerm_subscription.current.tenant_id}"
  subscription_id            = "${data.azurerm_subscription.current.subscription_id}"
  storage_use_azuread        = true
}

provider "azuread" {
 tenant_id                  = "${data.azurerm_subscription.current.tenant_id}"
}
EOT
}

resource "github_repository_file" "backend_tf" {
  repository     = github_repository.repository.name
  commit_message = "Configuring terraform backend to store state in your subscription"
  commit_author  = local.commit_author
  commit_email   = local.commit_email

  file    = "backend.tf"
  content = <<-EOT
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
