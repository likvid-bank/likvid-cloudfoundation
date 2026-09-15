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
    owning_workspace_identifier = "devops-platform"
  }

  # Same STACKIT organization the landing zone and bootstrap use. The backplane grants its automation
  # identity org-scoped roles here, so applying this unit needs the org-owner key (see terragrunt.hcl).
  stackit_organization_id = "05d7eb3f-f875-4bcd-ad0d-a07d62787f21"
}

# A dedicated meshProject for the STACKIT Service Account building block: it hosts the backplane
# automation identity and doubles as the target tenant the e2e smoke test orders an ephemeral service
# account into. Kept separate from stackit-storage-buckets so the two blocks do not share a project.
resource "meshstack_project" "stackit_service_account" {
  metadata = {
    owned_by_workspace = local.meshstack.owning_workspace_identifier
    name               = "stackit-service-account"
    display_name       = "STACKIT Service Account"
  }
  spec = {
    display_name              = "STACKIT Service Account"
    payment_method_identifier = "devops-platform-budget"
    tags = {
      Schutzbedarf         = ["public"]
      environment          = ["prod"]
      projectOwner         = ["Anna Admin"]
      LandingZoneClearance = ["cloud-native"]
    }
  }
}

# `meshstack_tenant.spec.platform_ref` needs a platform UUID, which only meshStack can supply, so the
# identifier is resolved into one here. The filter matches the full `<platform>.<location>` identifier;
# `one()` makes the unit fail loudly if it ever stops matching exactly one platform.
data "meshstack_platforms" "stackit" {
  identifier = "likvid-stackit.global"
}

resource "meshstack_tenant" "stackit_service_account" {
  metadata = {
    owned_by_workspace = local.meshstack.owning_workspace_identifier
    owned_by_project   = meshstack_project.stackit_service_account.metadata.name
  }

  spec = {
    platform_ref     = one(data.meshstack_platforms.stackit.platforms).ref
    landing_zone_ref = { name = "likvid-stackit-default" }
  }
}

module "stackit_service_account_bb" {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/${var.hub.module}?ref=${var.hub.git_ref}"

  hub                     = var.hub
  stackit_organization_id = local.stackit_organization_id
  stackit_project_id      = meshstack_tenant.stackit_service_account.spec.platform_tenant_id
  meshstack               = local.meshstack
}
