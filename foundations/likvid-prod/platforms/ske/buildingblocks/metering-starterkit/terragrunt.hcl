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
# for the STACKIT metering backplane, TCLOUD_FINANCIAL_DASHBOARD_API_KEY and
# MESHSTACK_API_SECRET_CUSTOM_MESHMETERING. They live only in Vault and not as GitHub secrets — skip from
# CI; run manually after sourcing setup-env.sh
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

# Only creates the short-lived SKE admin kubeconfig in main.tf.
provider "stackit" {
  alias               = "ske"
  service_account_key = var.stackit_ske_service_account_key
  default_region      = "eu01"
  experiments         = ["ske"]
}

# Short-lived admin kubeconfig, only for this run. The Kubernetes Service Account definition gets the
# long-lived token of the deployer service account the hub module creates with it.
provider "kubernetes" {
  host                   = local.admin_cluster["server"]
  cluster_ca_certificate = base64decode(local.admin_cluster["certificate-authority-data"])
  client_certificate     = base64decode(local.admin_user["client-certificate-data"])
  client_key             = base64decode(local.admin_user["client-key-data"])
}
PROVIDER
}

inputs = {
  hub                             = include.hub.locals
  stackit_project_id              = dependency.landingzone.outputs.foundation_project_id
  stackit_ske_service_account_key = get_env("STACKIT_SKE_PROJECT_SERVICE_ACCOUNT_KEY")
  stackit_org_service_account_key = get_env("STACKIT_ORG_SERVICE_ACCOUNT_KEY")
  tcloud_api_token                = get_env("TCLOUD_FINANCIAL_DASHBOARD_API_KEY")
  metering_api_secret             = get_env("MESHSTACK_API_SECRET_CUSTOM_MESHMETERING")
}
