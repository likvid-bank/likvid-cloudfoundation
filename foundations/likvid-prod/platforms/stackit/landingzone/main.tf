variable "hub" {
  type = object({
    architecture = string
    git_ref      = string
    bbd_draft    = bool
  })
  description = "Hub reference-architecture coordinates, from hub.hcl."
}

variable "stackit_service_account_key" {
  type        = string
  sensitive   = true
  description = "Key of the organization-scoped STACKIT service account the architecture deploys with."
}

locals {
  stackit_org = "05d7eb3f-f875-4bcd-ad0d-a07d62787f21"

  # Owner of the landing-zone folder and the foundation project the architecture creates.
  #
  # This must be the deploying service account itself, not a person. The architecture creates a
  # backplane service account *inside* the foundation project, and STACKIT grants project rights to
  # the project's owner. With a human owner the run fails with
  #   POST /v2/projects/<id>/service-accounts -> 403 Forbidden
  # because organization `resource-manager.admin` lets the account create a project but not act
  # inside it. The tenant-project building block already owns its projects the same way
  # (modules/stackit/project/buildingblock/main.tf:30, `owner_email = var.service_account_email`).
  #
  # The hub documents this input as needing only `resource-manager.admin`, which is not enough
  # unless the key is an organization owner, as it is in TCF.
  stackit_owner_email = "likvid-stackit-org-cbrue7i8@sa.stackit.cloud"

  # The demo meshStack requires LandingZoneFamily on every meshLandingZone, so the architecture
  # cannot create its landing zones without it.
  tags = {
    landingzone = {
      LandingZoneFamily = ["sandbox"]
      environment       = ["dev", "qa", "test", "prod"]
      confidentiality   = ["internal", "public"]
    }
    building_block = {
      LandingZoneClearance = ["sandbox"]
    }
  }
}

# The architecture owns a platform, so its workspace needs platform builder access. Keeping the
# workspace here rather than in the panel means the whole platform is one `terragrunt apply`.
#
# `meshstack_workspace` Create is a POST, not an upsert, so this fails with a conflict if the
# workspace already exists — adopt it with an `import` block instead of creating it by hand.
resource "meshstack_workspace" "stackit_platform" {
  metadata = {
    name = "stackit-platform"
    tags = {
      SecurityContact = ["cloudfoundation@likvid.io"]
      BusinessUnit    = ["IT"]
    }
  }

  spec = {
    display_name                    = "STACKIT Platform"
    platform_builder_access_enabled = true
  }

  # Destroying this workspace would take the platform, its landing zones and every tenant project
  # with it. The architecture's building block deletes its STACKIT resources on teardown.
  lifecycle {
    prevent_destroy = true
  }
}

module "stackit_landingzone" {
  source = "github.com/meshcloud/meshstack-hub//reference-architectures/stackit-landingzone?ref=${var.hub.git_ref}"

  meshstack = {
    owning_workspace_identifier = meshstack_workspace.stackit_platform.metadata.name
  }

  hub = {
    git_ref   = var.hub.git_ref
    bbd_draft = var.hub.bbd_draft
  }
}

resource "meshstack_building_block" "stackit_landingzone" {
  spec = {
    building_block_definition_version_ref = module.stackit_landingzone.building_block_definition.version_ref

    display_name = "STACKIT Landing Zone"
    target_ref   = meshstack_workspace.stackit_platform.ref

    inputs = {
      platform_identifier = { value = jsonencode("likvid-stackit") }

      # Without this the architecture creates its own meshLocation and the platform becomes
      # likvid-stackit.likvid-stackit instead of likvid-stackit.global.
      use_global_location = { value = jsonencode(true) }

      stackit_org         = { value = jsonencode(local.stackit_org) }
      stackit_owner_email = { value = jsonencode(local.stackit_owner_email) }
      tags                = { value = jsonencode(jsonencode(local.tags)) }

      # Project admins get `owner` so the demo can show real people working in STACKIT.
      role_mapping = { value = jsonencode(jsonencode({
        admin  = ["owner"]
        user   = ["editor"]
        reader = ["reader"]
      })) }

      stackit_service_account_key = { sensitive = {
        secret_value   = var.stackit_service_account_key
        secret_version = nonsensitive(sha256(var.stackit_service_account_key))
      } }
    }
  }
}

output "platform_identifier" {
  description = "Full identifier of the platform the architecture creates."
  value       = "likvid-stackit.global"
}

output "building_block_uuid" {
  description = "The architecture's building block, whose run holds the STACKIT folder and foundation project in state."
  value       = meshstack_building_block.stackit_landingzone.metadata.uuid
}
