variable "hub" {
  type = object({
    git_ref   = string
    bbd_draft = bool
  })
}

variable "stackit_project_id" {
  type        = string
  description = "Foundation project of the STACKIT landing zone, which holds the metering service accounts."
}

variable "stackit_ske_service_account_key" {
  type        = string
  sensitive   = true
  ephemeral   = true
  description = "Key of a STACKIT service account that may create admin kubeconfigs for the SKE cluster."
}

variable "stackit_org_service_account_key" {
  type        = string
  sensitive   = true
  ephemeral   = true
  description = "Key of a STACKIT service account that may create service accounts and assign roles on the organization."
}

variable "tcloud_api_token" {
  type        = string
  sensitive   = true
  description = "Admin API key of the T Cloud Financial Dashboard, valid for at most 90 days."
}

variable "metering_api_secret" {
  type        = string
  sensitive   = true
  description = "Password of the meshStack API user custom-meshmetering-repo, created in meshPanel."
}
