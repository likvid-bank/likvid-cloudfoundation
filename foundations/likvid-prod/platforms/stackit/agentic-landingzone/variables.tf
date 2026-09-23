variable "hub" {
  type = object({
    git_ref   = string
    bbd_draft = bool
  })
  description = "Hub coordinates for the nested integrations the architecture registers."
}

variable "buildingblock_git_ref" {
  type        = string
  description = "Commit of this repository that meshStack runs ./stackit-landingzone/buildingblock from."
}

variable "stackit_service_account_key" {
  type        = string
  sensitive   = true
  description = "Key of the organization-scoped STACKIT service account the architecture deploys with."
}
