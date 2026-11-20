variable "draft" {
  type        = bool
  description = "False releases the definition version. Application teams can only order a released version."
}

variable "building_block_git_ref" {
  type        = string
  description = "Ref of this repository the runs take the building block code from."
}

variable "meshstack_hub_git_ref" {
  type        = string
  description = "Ref of meshcloud/meshstack-hub for the runner identity lookup and the logo."
}

variable "stackit_ske_service_account_key" {
  type        = string
  sensitive   = true
  ephemeral   = true
  description = "Key of a STACKIT service account that may create admin kubeconfigs for the SKE cluster."
}
