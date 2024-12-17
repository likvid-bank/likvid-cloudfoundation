resource "google_project" "meshstack_root" {
  name                = var.project_id
  project_id          = var.project_id
  folder_id           = var.folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false
}

module "meshplatform" {
  source  = "meshcloud/meshplatform/gcp"
  version = "0.3.0"

  # common parameters
  project_id = data.google_project.meshstack_root.project_id
  org_id     = var.organization_id

  landing_zone_folder_ids                        = var.landing_zone_folder_ids
  can_delete_projects_in_landing_zone_folder_ids = var.can_delete_projects_in_landing_zone_folder_ids

  # required for replicator
  billing_org_id     = var.organization_id
  billing_account_id = var.billing_account_id

  # required for kraken
  cloud_billing_export_project_id = var.cloud_billing_export_project_id
  cloud_billing_export_dataset_id = var.cloud_billing_export_dataset_id
  cloud_billing_export_table_id   = var.cloud_billing_export_table_id

  kraken_sa_name     = var.kraken_sa_name
  replicator_sa_name = var.replicator_sa_name

  carbon_export_module_enabled   = var.carbon_export_module_enabled
  cloud_carbon_export_dataset_id = var.carbon_footprint_dataset_id
  cloud_carbon_export_project_id = var.cloud_billing_export_project_id

  service_account_keys         = var.service_account_keys
  workload_identity_federation = var.workload_identity_federation
}
