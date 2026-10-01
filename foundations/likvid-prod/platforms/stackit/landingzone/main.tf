module "this" {
  source = "github.com/meshcloud/meshstack-hub//reference-architectures/stackit-landingzone?ref=${var.hub.git_ref}"

  meshstack = {
    owning_workspace_identifier = meshstack_workspace.this.metadata.name
  }

  hub = {
    git_ref   = var.hub.git_ref
    bbd_draft = var.hub.bbd_draft
  }

  # Gates on the definition itself, switched on in meshPanel. The provider asserts its own defaults
  # whenever a definition sets no policies, so leaving these out turns them off on the next apply.
  # Gates exist only on definitions; an ordered block has none of its own.
  approval_policies = {
    manual_triggers = true
    version_upgrade = true
  }

  # This platform is really used, so it takes the plain identifier and keeps its destroy guards.
  playground_mode = false
}

resource "meshstack_building_block" "this" {
  spec = {
    building_block_definition_version_ref = module.this.building_block_definition.version_ref

    display_name = "STACKIT Landing Zone"
    target_ref   = meshstack_workspace.this.ref

    inputs = {
      platform_identifier = { value = jsonencode("likvid-stackit") }

      # Without this the architecture creates its own meshLocation and the platform becomes
      # `likvid-stackit.likvid-stackit` instead of `likvid-stackit.global`.
      use_global_location = { value = jsonencode(true) }

      stackit_org = { value = jsonencode("05d7eb3f-f875-4bcd-ad0d-a07d62787f21") }

      # A mailbox rather than the deploying service account, which is why that account has to be an
      # organization owner. STACKIT applies the owner at creation only, so changing this value leaves
      # the existing folder and project with the old owner.
      stackit_owner_email = { value = jsonencode("stackit@meshcloud.io") }

      tags = { value = jsonencode(jsonencode({
        # The policy "Enforce Landing Zone Family clearance" intersects `LandingZoneFamily` with a
        # project's `LandingZoneClearance`, and both are single-select, so the two must be equal.
        landingzone = [
          { key = "LandingZoneFamily", values = ["cloud-native"] },
          { key = "environment", values = ["dev", "qa", "test", "prod"] },
          { key = "confidentiality", values = ["internal", "public"] },
        ]

        building_block = [
          { key = "LandingZoneClearance", values = ["cloud-native"] },
        ]

        # Tags for the meshProjects the STACKIT Project Starterkit creates. `LandingZoneClearance` and
        # `Schutzbedarf` are mandatory on this instance and have no default, so a starterkit that
        # passes no tags cannot create a project at all.
        project = [
          { key = "LandingZoneClearance", values = ["cloud-native"] },
          { key = "Schutzbedarf", values = ["internal"] },
          { key = "environment", values = ["dev"] },
          { key = "ResponsibilityLevel", values = ["Cloud Pro"] },
        ]
        project_owner_tag_key = "projectOwner"
      })) }

      topology = { value = jsonencode(["sandbox", "hub&spoke"]) }

      # Setting this creates the second landing zone `likvid-stackit-networked` plus the self-service
      # `STACKIT Network` building block. The seven existing tenants keep the unnetworked variant.
      network = { value = jsonencode(jsonencode({
        # `10.1.255.0/24` sits inside the range of the live area `meshcloud-test`, which is harmless
        # only while the two areas are never connected. `10.20.0.0/16` with transfer `10.21.255.0/24`
        # is free across the whole organization.
        hub_network_area_name     = "likvid-stackit-1"
        hub_network_ranges        = ["10.0.0.0/16"]
        hub_transfer_network      = "10.1.255.0/24"
        hub_min_prefix_length     = 24
        hub_max_prefix_length     = 28
        hub_default_prefix_length = 28
        hub_default_nameservers   = []
      })) }

      # Project admins get `owner` so the demo can show real people working in the STACKIT portal.
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

  # The definition is `deletion_mode = "DELETE"`, so destroying this block tears down the
  # `likvid-stackit` folder with all seven live tenant projects inside it, including the SKE cluster.
  lifecycle {
    prevent_destroy = true

    postcondition {
      condition     = self.status.status == "SUCCEEDED"
      error_message = "Building block ${self.metadata.uuid} is ${self.status.status}, not SUCCEEDED. See its run in meshPanel."
    }
  }
}

resource "meshstack_workspace" "this" {
  metadata = {
    name = "stackit-platform"
    tags = {
      SecurityContact = ["cloudfoundation@likvid.io"]
      BusinessUnit    = ["IT"]

      # The policy `Workspace-Project` intersects this with `meshProject.environment`, so a project
      # can only exist in an environment its workspace also carries. Unset, the intersection is empty
      # and every project creation in this workspace fails with a 403.
      environment = ["dev", "qa", "test", "prod"]
    }
  }

  spec = {
    display_name                    = "STACKIT Platform"
    platform_builder_access_enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}