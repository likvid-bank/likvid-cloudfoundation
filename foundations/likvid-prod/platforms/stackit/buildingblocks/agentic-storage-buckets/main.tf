variable "stackit_project_id" {
  description = "STACKIT project that already hosts the devops-platform storage buckets"
  type        = string
}

variable "hub" {
  description = "Hub building-block coordinates (single source of truth in hub.hcl, passed in by terragrunt)"
  type = object({
    module    = string
    git_ref   = string
    bbd_draft = bool
  })
}

locals {
  meshstack = {
    owning_workspace_identifier = "agentic-platform"
  }
}

# A second storage bucket offering, for live demos of an agent that maintains a building block.
# The agent pushes to the hub branch in hub.hcl and asks meshStack for a run. It never applies
# anything itself, and these gates make a human approve every run except the first.
module "stackit_storage_bucket_bb" {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/${var.hub.module}?ref=${var.hub.git_ref}"

  hub                = var.hub
  stackit_project_id = var.stackit_project_id
  meshstack          = local.meshstack

  # Shares the project with ../storage-buckets, so the backplane needs its own service account.
  stackit_service_account_name = "agentic-bucket"
  bbd_display_name             = "STACKIT Storage Bucket (agentic demo)"

  approval_policies = {
    manual_triggers    = true
    user_input_changes = true
    any_input_changes  = true
    version_upgrade    = true
  }
}
