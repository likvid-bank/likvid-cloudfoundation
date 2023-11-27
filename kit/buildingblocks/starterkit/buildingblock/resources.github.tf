# note: this building block is expected to be executed with a config.tf file as output by the "backplane" module in the
# parent dir, this needs to provided in the BB execution enviornment

resource "github_repository" "repository" {
  name        = var.repo_name
  description = "Created from a Likvid Bank DevOps Toolchain starter kit for ${var.workspace_identifier}.${var.project_identifier}"
  visibility  = "private"

  topics = ["starterkit"]

  auto_init            = true
  vulnerability_alerts = true

  lifecycle {
    ignore_changes = [description]
  }

  template {
    owner      = var.template_owner
    repository = var.template_repo
  }
}

# In theory these settings could also be copied from the template repository, however it's unclear whether this is
# supported for every setting we care about. Having them in the BB instead of the backplane has the following benefits
# - we can decide to upgrade these rules on existing repos with a BB definition version upgrade
# - we have important concepts like the sandbox environment available for cross-referencing in other resources and don't
#   need "magic constants" here

resource "github_repository_environment" "sandbox" {
  environment = "sandbox"
  repository  = github_repository.repository.name

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "sandbox" {
  repository     = github_repository.repository.name
  environment    = github_repository_environment.sandbox.environment
  branch_pattern = "main"
}

#
# Files
#


#
# add pipeline file to repo
#

locals {
  commit_author = "DevOps Toolchain Team"
  commit_email  = "devopstoolchain@likvid-bank.com"
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


resource "github_repository_file" "deploy_yml" {
  # important: make sure to only deploy the pipeline after the terraform code has been committed or else 
  # the first pipeline run will fail, which doesn't exactly help build confidence in application teams ;-)
  depends_on     = [github_repository_file.provider_tf, github_repository_file.backend_tf]
  
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
