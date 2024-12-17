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
# todo: add provider {} blocks as needed
EOF
}

terraform {
  source = "${get_repo_root()}//kit/gcp/meshplatform"
}

inputs = {
  # todo: set input variables
  project_id = include.platform.locals.platform.gcp.project
  org_id     = include.platform.locals.platform.gcp.organization
  landing_zone_folder_ids = [
    "981198366660", # Data Lagoon
    "956712559912", # likvid-dev
    "145203092684"  # likvid-prod
  ]
  can_delete_projects_in_landing_zone_folder_ids = []
  # required for replicator
  billing_org_id     = include.platform.locals.platform.gcp.organization
  billing_account_id = include.platform.locals.platform.gcp.billing_account

  # required for kraken
  cloud_billing_export_project_id = include.platform.locals.platform.gcp.billingExport.project
  cloud_billing_export_dataset_id = "${include.platform.locals.platform.gcp.billingExport.project}.${include.platform.locals.platform.gcp.billingExport.dataset}"
  cloud_billing_export_table_id   = "${include.platform.locals.platform.gcp.billingExport.project}.${include.platform.locals.platform.gcp.billingExport.dataset}.gcp_billing_export_v1_${include.platform.locals.platform.gcp.billing_account}"

  kraken_sa_name     = "likvid-kraken"
  replicator_sa_name = "likvid-replicator"

  carbon_export_module_enabled   = true
  cloud_carbon_export_dataset_id = "${include.platform.locals.platform.gcp.carbonExport.project}.${include.platform.locals.platform.gcp.carbonExport.dataset}.${include.platform.locals.platform.gcp.carbonExport.table}"

  service_account_keys = true
}