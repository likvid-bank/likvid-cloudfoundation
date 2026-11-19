include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "tfstate" {
  path = find_in_parent_folders("tfstate.hcl")
}

include "hub" {
  path   = "./hub.hcl"
  expose = true
}

# Needs STACKIT_SKE_PROJECT_SERVICE_ACCOUNT_KEY for an SKE admin kubeconfig, STACKIT_ORG_SERVICE_ACCOUNT_KEY
# for the STACKIT metering backplane and
# MESHSTACK_API_SECRET_CUSTOM_MESHMETERING from Vault, an SSH key that can clone the private
# meshcloud/mesh-custom-metering, and a GitHub login (`gh auth login` or GITHUB_TOKEN) as admin of that
# repo for its deploy key. Skip from CI; run manually after sourcing setup-env.sh
exclude {
  if      = true
  actions = ["plan", "test"]
}

dependency "landingzone" {
  config_path = "../../../stackit/landingzone"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<PROVIDER
provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  workspace = "devops-platform"
}

# Creates the STACKIT metering service accounts and assigns the cost reader role on the organization.
provider "stackit" {
  service_account_key = var.stackit_org_service_account_key
  default_region      = "eu01"
  experiments         = ["iam"]
}

# Only creates the SKE admin kubeconfig in main.tf.
provider "stackit" {
  alias               = "ske"
  service_account_key = var.stackit_ske_service_account_key
  default_region      = "eu01"
  experiments         = ["ske"]
}

provider "github" {
  owner = "meshcloud"
}
PROVIDER
}

inputs = {
  hub                             = include.hub.locals.hub
  meshstack_hub_git_ref           = include.hub.locals.meshstack_hub_git_ref
  stackit_project_id              = dependency.landingzone.outputs.foundation_project_id
  stackit_ske_service_account_key = get_env("STACKIT_SKE_PROJECT_SERVICE_ACCOUNT_KEY")
  stackit_org_service_account_key = get_env("STACKIT_ORG_SERVICE_ACCOUNT_KEY")
  metering_api_secret             = get_env("MESHSTACK_API_SECRET_CUSTOM_MESHMETERING")
}
