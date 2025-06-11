include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "organization" {
  config_path = "../admin/organization"
}

dependency "bootstrap" {
  config_path = "../bootstrap"
}

# todo: setup providers as needed by your kit module, typically referencing outputs of the bootstrap module
# note: this block is generated as a fallback, since the kit module provided no explicit terragrunt.hcl template
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "google" {
  region      = "europe-west3"
}
EOF
}

terraform {
  source = "${get_repo_root()}//kit/gcp/meshplatform"
}

inputs = {

  # meshplatform module

  project_id      = include.platform.locals.platform.gcp.project
  organization_id = include.platform.locals.platform.gcp.organization
  folder_id       = dependency.organization.outputs.admin_folder_id

  landing_zone_folder_ids = [
    "981198366660", # Data Lagoon
    "956712559912", # likvid-dev
    "145203092684"  # likvid-prod
  ]

  # required for replicator
  billing_org_id     = include.platform.locals.platform.gcp.organization
  billing_account_id = include.platform.locals.platform.gcp.billingAccount

  # required for kraken
  cloud_billing_export_project_id = include.platform.locals.platform.gcp.billingExport.project
  cloud_billing_export_dataset_id = include.platform.locals.platform.gcp.billingExport.dataset
  cloud_billing_export_table_id   = "${include.platform.locals.platform.gcp.billingExport.project}.${include.platform.locals.platform.gcp.billingExport.dataset}.gcp_billing_export_v1_${include.platform.locals.platform.gcp.billingAccount}"

  kraken_sa_name     = "likvid-kraken"
  replicator_sa_name = "likvid-replicator"

  carbon_export_module_enabled = true
  carbon_footprint_dataset_id  = include.platform.locals.platform.gcp.carbonExport.dataset

  service_account_keys = false
  workload_identity_federation = {
    workload_identity_pool_identifier = "meshcloud-demo"
    issuer                            = "https://container.googleapis.com/v1/projects/meshcloud-meshcloud--bc0/locations/europe-west1/clusters/meshstacks-ha"
    audience                          = "gcp-workload-identity-provider:meshcloud-demo"
    replicator_subject                = "system:serviceaccount:meshcloud-demo:replicator"
    kraken_subject                    = "system:serviceaccount:meshcloud-demo:kraken-worker"
  }

  # deploy user permissions

  deploy_principal = {
    id   = "group:${dependency.bootstrap.outputs.platform_engineers_group_email}"
    name = dependency.bootstrap.outputs.platform_engineers_group_name
  }
}
