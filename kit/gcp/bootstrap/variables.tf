variable "billing_account_id" {
  type        = string
  description = "id of the billing account for projects"
}

variable "parent_folder_id" {
  type        = string
  description = "Folder if of the parent folder hosting this foundation"
}

variable "foundation_project_id" {
  type        = string
  description = "Project ID of the GCP Project hosting foundation-level resources for this foundation"
}

variable "service_account_name" {
  type        = string
  description = "name of the Service Account used to deploy cloud foundation resources"
  default     = "foundation-tf-deploy-user"
}

variable "tf_state_bucket_name" {
  type        = string
  default     = null
  description = "name of the GCS bucket to create for hosting foundation-level terraform states"
}

variable "region" {
  type        = string
  description = "GCP region where to create cresources"
}

variable "platform_engineers_group" {
  type = object({
    name    = string,
    members = set(string),
    domain  = string
  })
  description = "Name of the platform engineers group"
}

variable "foundation" {
  type        = string
  description = "name of the foundation"
}

variable "github_repo_full_name" {
  type        = string
  description = "Full name of the GitHub repo incl. owner e.g. likvid-bank/likvid-cloudfoundation"
}

variable "github_repo_enable_tf_state_access" {
  type        = bool
  description = "allow github actions access to terraform state"
}
