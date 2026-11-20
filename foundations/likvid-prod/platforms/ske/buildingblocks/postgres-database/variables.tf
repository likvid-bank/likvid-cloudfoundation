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

variable "stackit_access_token" {
  type        = string
  sensitive   = true
  ephemeral   = true
  description = "Access token of a STACKIT login that may create Secrets Manager users in the platform's project."
}
