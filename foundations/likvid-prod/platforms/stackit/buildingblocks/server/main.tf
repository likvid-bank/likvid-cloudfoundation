variable "hub" {
  description = "Hub building-block coordinates (single source of truth in hub.hcl, passed in by terragrunt)"
  type = object({
    module    = string
    git_ref   = string
    bbd_draft = bool
  })
}

variable "stackit_project_id" {
  description = "Foundation project of the STACKIT landing zone, which hosts the backplane service account."
  type        = string
}

variable "stackit_service_account_key" {
  description = "Key of the organization-scoped STACKIT service account the landing zone deploys with."
  type        = string
  sensitive   = true
}

module "stackit_server_bb" {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/${var.hub.module}?ref=${var.hub.git_ref}"

  hub = {
    git_ref   = var.hub.git_ref
    bbd_draft = var.hub.bbd_draft
  }

  stackit_organization_id = "05d7eb3f-f875-4bcd-ad0d-a07d62787f21"
  stackit_project_id      = var.stackit_project_id

  meshstack = {
    owning_workspace_identifier = "stackit-platform"

    # The building block tag the landing zone puts on the definitions it registers, so the policy
    # "Enforce Landing Zone Family clearance" offers this one on the same tenants.
    tags = { LandingZoneClearance = ["cloud-native"] }
  }
}
