variable "deploy_principal" {
  type = object({
    name = string
    id   = string
  })
  nullable    = false
  description = "name and id of the principal allowed to deploy cloud foundation resources"
}

variable "project_id" {
  type        = string
  description = "GCP Project ID where to create the resources. This is typically a 'meshstack-root' project."
}

variable "folder_id" {
  type        = string
  nullable    = false
  description = "id of the parent folder to the project (see project_id)"
}

variable "organization_id" {
  type        = string
  description = "GCP Organization ID that holds the projects that generate billing data that the service account should import."
}

variable "billing_org_id" {
  type        = string
  description = "GCP organization ID that holds billing account."
}

variable "billing_account_id" {
  type        = string
  description = "The GCP billing account in your organization."
}

variable "landing_zone_folder_ids" {
  type        = list(string)
  description = "GCP Folders that make up the Landing Zone. The service account will only receive permissions on these folders."
}

variable "cloud_billing_export_project_id" {
  type        = string
  description = "GCP Project where the BiqQuery table resides that holds the Cloud Billing export to BigQuery. See https://cloud.google.com/billing/docs/how-to/export-data-bigquery"
}

variable "cloud_billing_export_dataset_id" {
  type        = string
  description = "GCP BigQuery dataset containing the Cloud Billing BigQuery export. This variable is only required to form the output for meshPlatform configuration. No resources are created or attached."
}

variable "cloud_billing_export_table_id" {
  type        = string
  description = "GCP BigQuery table containing the Cloud Billing BigQuery export. This variable is only required to form the output for meshPlatform configuration. No resources are created or attached."
}

# ---------------------------------------------------------------------------------------------------------------------
# PARAMETERS to enable optional modules
# ---------------------------------------------------------------------------------------------------------------------

variable "carbon_export_module_enabled" {
  type        = bool
  description = "Determines whether or not to include the resources of the carbon footprint export module."
  default     = false
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "replicator_sa_name" {
  type        = string
  description = "Name of the service account to create for Replicator."
  default     = "mesh-replicator-service-tf"
}

variable "kraken_sa_name" {
  type        = string
  description = "Name of the service account to create for Kraken."
  default     = "mesh-kraken-service-tf"
}

variable "carbon_footprint_dataset_id" {
  type        = string
  description = "Id of BigQuery dataset for carbon footprint."
}

variable "service_account_keys" {
  default     = true
  type        = bool
  description = "Create service account keys for authentication."
}

variable "workload_identity_federation" {
  default = null
  type = object({
    workload_identity_pool_identifier = string
    issuer                            = string
    audience                          = string
    replicator_subject                = string
    kraken_subject                    = string
  })
  description = "Setup workload identity federation for authentication."
}
