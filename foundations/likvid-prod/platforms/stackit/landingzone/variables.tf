variable "hub" {
  type = object({
    git_ref   = string
    bbd_draft = bool
  })
  description = "Hub reference-architecture coordinates."
}

variable "stackit_service_account_key" {
  type        = string
  sensitive   = true
  description = "Key of the organization-scoped STACKIT service account the architecture deploys with."
}
