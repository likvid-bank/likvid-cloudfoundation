module "meshplatform" {
  source  = "meshcloud/meshplatform/gcp"
  version = "0.3.0"

  # common parameters
  project_id = var.project_id
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

# give our deploy user sufficient permissions to perform the required actions on this project
resource "google_project_iam_custom_role" "cloudfoundation_deploy" {
  role_id     = "${replace(var.deploy_principal.name, "-", "_")}_meshplatform"
  project     = var.project_id
  title       = "${var.deploy_principal.name} service project role (meshplatform)"
  description = "Role for ${var.deploy_principal.name} service account used for deploying the cloud foundation"
  permissions = [
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.list",
    "iam.serviceAccounts.create",
    "iam.serviceAccounts.update",
    "iam.serviceAccounts.delete",

    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.setIamPolicy",

    "iam.serviceAccountKeys.get",
    "iam.serviceAccountKeys.list",
    "iam.serviceAccountKeys.create",
    "iam.serviceAccountKeys.delete",

    "iam.workloadIdentityPools.get",
    "iam.workloadIdentityPools.list",
    "iam.workloadIdentityPoolProviders.get",
    "iam.workloadIdentityPoolProviders.list",
  ]
}

resource "google_project_iam_custom_role" "cloudfoundation_deploy_billing_project" {
  role_id     = "${replace(var.deploy_principal.name, "-", "_")}_meshplatform"
  project     = var.cloud_billing_export_project_id
  title       = "${var.deploy_principal.name} service project role (meshplatform)"
  description = "Role for ${var.deploy_principal.name} service account used for deploying the cloud foundation on billing project"
  permissions = [
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.list",
    "iam.serviceAccounts.create",
    "iam.serviceAccounts.update",
    "iam.serviceAccounts.delete",

    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.setIamPolicy",

    "iam.serviceAccountKeys.get",
    "iam.serviceAccountKeys.list",
    "iam.serviceAccountKeys.create",
    "iam.serviceAccountKeys.delete",

    "iam.workloadIdentityPools.get",
    "iam.workloadIdentityPools.list",
    "iam.workloadIdentityPoolProviders.get",
    "iam.workloadIdentityPoolProviders.list",

    "bigquery.datasets.get",
    "bigquery.datasets.update",
    "bigquery.jobs.create",
    "bigquery.transfers.get",
    "bigquery.transfers.update",
  ]
}


# assign the custom role to the deploy user
resource "google_project_iam_member" "cloudfoundation_deploy" {
  project = var.project_id
  role    = google_project_iam_custom_role.cloudfoundation_deploy.id
  member  = var.deploy_principal.id
}

resource "google_bigquery_dataset_iam_member" "cloudfoundation_deploy_billing" {
  project    = var.cloud_billing_export_project_id
  dataset_id = var.cloud_billing_export_dataset_id

  member = var.deploy_principal.id
  role   = google_project_iam_custom_role.cloudfoundation_deploy_billing_project.id
}

resource "google_bigquery_dataset_iam_member" "cloudfoundation_deploy_carbon" {
  project    = var.cloud_billing_export_project_id
  dataset_id = var.carbon_footprint_dataset_id

  member = var.deploy_principal.id
  role   = google_project_iam_custom_role.cloudfoundation_deploy_billing_project.id
}
