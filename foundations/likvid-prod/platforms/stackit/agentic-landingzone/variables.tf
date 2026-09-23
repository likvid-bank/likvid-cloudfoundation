variable "hub" {
  type = object({
    git_ref   = string
    bbd_draft = bool
  })
  description = "Hub coordinates for the nested integrations the architecture registers."

  # Sources the nested hub integrations that the building block registers. The architecture itself is
  # the local copy in this unit.
  default = {
    git_ref   = "b70efaad7de7fccf2dcb513d94db6308295261a0"
    bbd_draft = true
  }
}

variable "buildingblock_git_ref" {
  type        = string
  description = "Commit of this repository that meshStack runs ./buildingblock from. A commit sha: with a branch, a push would change what the next run executes without a new definition version."

  # meshStack checks this commit out from GitHub, so it must be pushed. A change to the building
  # block code takes two commits: the change itself, then this pin moved onto it.
  default = "18f33b07b0cf6cf39dd0e71c2d1d4e495c713628"
}

variable "stackit_service_account_email" {
  type        = string
  description = "Organization-owner service account the architecture runs as through WIF."

  # The organization owner whose key the live landingzone unit uses. For this unit it needs the WIF
  # trust from the `workload_identity_federation` output instead.
  default = "bootstrap-sa-4yfw9wi8@sa.stackit.cloud"
}
