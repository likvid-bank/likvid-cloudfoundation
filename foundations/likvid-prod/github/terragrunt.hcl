include "common" {
  path = find_in_parent_folders("common.hcl")
}

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

dependency "aws_bootstrap" {
  config_path = "../platforms/aws/bootstrap"
}

dependency "azure_bootstrap" {
  config_path = "../platforms/azure/bootstrap"
}

dependency "gcp_bootstrap" {
  config_path = "../platforms/gcp/bootstrap"
}

locals {
  azure         = yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file("../platforms/azure/README.md"))[0]).azure
  aws           = yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file("../platforms/aws/README.md"))[0]).aws
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
    aws_iam_role = dependency.aws_bootstrap.outputs.validation_iam_role_arn

    azure_client_id       = dependency.azure_bootstrap.outputs.validation_uami_client_id
    azure_tenant_id       = local.azure.aadTenantId
    azure_subscription_id = local.azure.subscriptionId

    gcp_service_account            = dependency.gcp_bootstrap.outputs.github_actions_validation_sa_email
    gcp_workload_identity_provider = dependency.gcp_bootstrap.outputs.github_actions_workload_identity_provider
  }

  actions_secrets = {
    MESHSTACK_API_KEY_STATIC_WEBSITE_ASSETS = get_env("MESHSTACK_API_KEY_STATIC_WEBSITE_ASSETS")
    MESHSTACK_API_KEY_CLOUDFOUNDATION       = get_env("MESHSTACK_API_KEY_CLOUDFOUNDATION")
    MESHSTACK_API_PASSWORD                  = get_env("MESHSTACK_API_PASSWORD")
    ACTIONS_GITHUB_APP_PEM_FILE             = get_env("GITHUB_APP_PEM_FILE") # note: secrets may not start with GITHUB_ prefix
    # note: there's currently some more secrets managed outside of this repo still
  }
}
