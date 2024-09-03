terraform {
  source = "${get_repo_root()}//kit/foundation/github"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "github" {
  owner = "likvid-bank"
}
EOF
}

dependency "azure_bootstrap" {
  config_path = "../platforms/azure/bootstrap"
}

locals {
  azure         = yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file("../platforms/azure/README.md"))[0]).azure
  tfstateconfig = yamldecode(file("${get_repo_root()}//foundations/likvid-prod/platforms/azure/tfstates-config.yml"))
}


# We store our state with the Azure platform because that was the first platform bootstrapped for likvid-bank (could have used any other)
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "azurerm" {
    use_azuread_auth      = true
    tenant_id             = "${local.azure.aadTenantId}"
    subscription_id       = "${local.azure.subscriptionId}"
    resource_group_name   = "${local.tfstateconfig.resource_group_name}"
    storage_account_name  = "${local.tfstateconfig.storage_account_name}"
    container_name        = "${local.tfstateconfig.container_name}"
    key                   = "github.tfstate"
  }
}
EOF
}


inputs = {
  github_repo = "likvid-cloudfoundation"
  foundation  = "likvid-prod"
  actions_variables = {
    azure_client_id       = dependency.azure_bootstrap.outputs.validation_uami_client_id
    azure_tenant_id       = local.azure.aadTenantId
    azure_subscription_id = local.azure.subscriptionId
  }
}