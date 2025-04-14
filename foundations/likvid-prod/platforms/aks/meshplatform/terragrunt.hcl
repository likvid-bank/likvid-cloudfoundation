include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

# todo: setup providers as needed by your kit module, typically referencing outputs of the bootstrap module
# note: this block is generated as a fallback, since the kit module provided no explicit terragrunt.hcl template
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "aks"
  host           = "https://dev-oug61sf3.hcp.germanywestcentral.azmk8s.io:443"
}

provider "azuread" {
  tenant_id       = "${include.platform.locals.platform_azure.azure.aadTenantId}"
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  tenant_id       = "${include.platform.locals.platform_azure.azure.aadTenantId}"
  subscription_id = "${include.platform.locals.platform_azure.azure.subscriptionId}"
}
EOF

}

terraform {
  source = "${get_repo_root()}//kit/aks/meshplatform"
}

inputs = {
  # metering and replicator are enabled in dev ICF 
  metering_enabled   = false
  replicator_enabled = false

  service_principal_name = "aks_replicator.${include.platform.locals.cloudfoundation}.meshcloud.io"
  create_password        = false
  workload_identity_federation = {
    issuer             = "https://container.googleapis.com/v1/projects/meshcloud-meshcloud--bc0/locations/europe-west1/clusters/meshstacks-ha"
    replicator_subject = "system:serviceaccount:meshcloud-demo:replicator"
  }
  scope = "7490f509-073d-42cd-a720-a7f599a3fd0b"
}
