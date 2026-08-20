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
  # A mailbox rather than the deploying service account, so the STACKIT portal shows a real owner.
  # This only works because the deployment key is an organization owner: the architecture creates a
  # service account *inside* the foundation project, which is a project-level operation, and
  # `resource-manager.admin` alone cannot do that in a project it does not own. Deploying with such
  # a narrow key and a mailbox owner fails with
  #   POST /v2/projects/<id>/service-accounts -> 403 Forbidden
  #
  # This matches TCF, which uses the same key and the same owner.
  #
  # STACKIT applies owner_email at creation only. Changing it here updates Terraform state but
  # leaves the existing owner in place — the folder and project must be recreated for it to take
  # effect.
  stackit_owner_email = "stackit@meshcloud.io"

  # LandingZoneFamily is mandatory on every meshLandingZone here, and it is enforced: the policy
  # "Enforce Landing Zone Family clearance" intersects meshProject.LandingZoneClearance with it.
  # Both are single-select, so the intersection is equality — a landing zone tagged `sandbox` is
  # unusable by every project we intend to migrate, all seven of which are `cloud-native`.
  #
  # `cloud-native` also describes the landing zone correctly: it hands out a STACKIT project to
  # build in. A future SKE-namespace variant would be `container-platform` instead, which is why
  # this belongs per landing zone rather than per deployment.
  #
  # environment and confidentiality are matched the same way, against meshProject.environment and
  # meshProject.Schutzbedarf, so they list every value a migrating project uses.
  tags = {
    landingzone = {
      LandingZoneFamily = ["cloud-native"]
      environment       = ["dev", "qa", "test", "prod"]
      confidentiality   = ["internal", "public"]
    }
    # No policy can target a building block definition — PolicySubjectType has no such subject — so
    # this is descriptive only.
    building_block = {
      LandingZoneClearance = ["cloud-native"]
    }

    # Tags for the meshProjects the STACKIT Project Starterkit creates. Four `meshProject` tag
    # definitions on this instance are mandatory — `projectOwner`, `environment`, `LandingZoneClearance`
    # and `Schutzbedarf` — and the last two carry no default value at all, so a starterkit that passes
    # no tags cannot create a project here.
    #
    # `LandingZoneClearance` has to be `cloud-native`: the policy "Enforce Landing Zone Family
    # clearance" intersects it with the landing zone's `LandingZoneFamily`, and both landing zones
    # carry `cloud-native`.
    #
    # `environment = dev` because the starterkit is stageless — one order, one project. A team that
    # needs a production project changes the tag afterwards, or orders again once the starterkit grows
    # a stage input.
    #
    # These values match what the live SKE Starterkit passes for its dev stage, so the two starterkits
    # produce comparably tagged projects.
    project = {
      LandingZoneClearance = ["cloud-native"]
      Schutzbedarf         = ["internal"]
      environment          = ["dev"]
      ResponsibilityLevel  = ["Cloud Pro"]
    }
    project_owner_tag_key = "projectOwner"
  }

  # Hub-and-spoke networking. Setting this is what creates the second landing zone
  # `likvid-stackit-networked`, so the starterkit's landing-zone select shows two options instead of
  # one, plus the self-service `STACKIT Network` building block for routed spoke subnets.
  #
  # The seven existing tenants are untouched: they sit on the `default` project variant, which passes
  # `network_area_id = null` and carries no `networkArea` label.
  #
  # The address plan is copied from the `hub-demo-test-1` demo area, which STACKIT accepted and which
  # `hub-demo-bnd2` and `mcdev-pltfm-hub-prod` also run — network areas are independent routing
  # domains, so identical ranges across areas are allowed and already the norm in this organization.
  #
  # One overlap to know about: `transfer 10.1.255.0/24` sits inside the range `10.1.0.0/16` of the
  # live area `meshcloud-test`, which has four projects attached. Harmless while the two areas are
  # never connected, and the two demo areas above already do the same. If that ever needs to be
  # clean, `10.20.0.0/16` with transfer `10.21.255.0/24` is free across the whole organization.
  #
  # `tenant_network_min_prefix_length` and `tenant_network_max_prefix_length` are left to the
  # architecture's defaults of 24 and 28, which match the hub bounds set here.
  #
  # Applied on 2026-08-20. The area is `57146b2c-aef7-4666-8e4d-7171a56ea9c2`, held by the nested
  # `Hub Network Area` building block, not by this unit.
  network = {
    hub_network_area_name     = "likvid-stackit-1"
    hub_network_ranges        = ["10.0.0.0/16"]
    hub_transfer_network      = "10.1.255.0/24"
    hub_min_prefix_length     = 24
    hub_max_prefix_length     = 28
    hub_default_prefix_length = 28
    hub_default_nameservers   = []
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

      # Not decoration. The panel-managed policy `Workspace-Project` intersects this multi-select with
      # `meshProject.environment`, so a project can only exist in an environment its workspace also
      # carries. With this unset the intersection is empty and every project creation in the workspace
      # is refused with a 403 `PolicyErrorResponse`, which is what the first starterkit test hit:
      #
      #   authoritativeSubject STACKIT Platform tag environment []
      #   affectedSubject      sk-sandbox       tag environment ["dev"]
      #
      # All four values, matching `devops-platform`, which hosts the SKE and AKS starterkits and is
      # the working precedent on this instance.
      environment = ["dev", "qa", "test", "prod"]
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

      # `CODE` inputs are double-encoded, same as `tags` above: meshStack stores the JSON document as
      # a string, so the outer jsonencode wraps the inner one.
      network = { value = jsonencode(jsonencode(local.network)) }

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

  # The architecture's building block definition is `deletion_mode = "DELETE"`, so destroying this
  # block runs its teardown: the `likvid-stackit` folder goes with every tenant project inside it, and
  # so do the landing zone, the building block definitions and the project-creation service account.
  # Seven live tenant projects sit in that folder, including the one running the SKE cluster.
  lifecycle {
    prevent_destroy = true
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

# Building block outputs arrive JSON-encoded, which is why this needs the jsondecode — the REST API
# renders the same field decoded, which is misleading.
output "starterkit_bbd_version_uuid" {
  description = "Version uuid of the STACKIT Project Starterkit definition the architecture registered. Kept as the way a sibling unit can order starterkit instances as code — the definition is created inside the architecture's own run, so there is no module output to read it from."
  value       = jsondecode(meshstack_building_block.stackit_landingzone.status.outputs["starterkit_bbd_version_uuid"].value)
}
