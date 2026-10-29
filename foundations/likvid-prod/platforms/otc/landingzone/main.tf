module "this" {
  source = "github.com/meshcloud/meshstack-hub//reference-architectures/otc-landingzone?ref=${var.hub.git_ref}"

  meshstack = {
    owning_workspace_identifier = meshstack_workspace.this.metadata.name
  }

  hub = {
    git_ref   = var.hub.git_ref
    bbd_draft = var.hub.bbd_draft
  }

  # Gates on the definition itself, switched on in meshPanel. The provider asserts its own defaults
  # whenever a definition sets no policies, so leaving these out turns them off on the next apply.
  # Separate from the gates on `meshstack_building_block.this` below, which are on the ordered block.
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

    display_name = "T Cloud Public Landing Zone"
    target_ref   = meshstack_workspace.this.ref

    approval_policies = {
      any_input_changes  = true
      manual_triggers    = true
      user_input_changes = true
      version_upgrade    = true
    }

    inputs = {
      platform_identifier = { value = jsonencode("likvid-otc") }

      # Without this the architecture creates its own meshLocation and the platform becomes
      # `likvid-otc.likvid-otc` instead of `likvid-otc.global`.
      use_global_location = { value = jsonencode(true) }

      # Shared with the hub's test deployment, so every name this landing zone creates in the domain
      # carries `likvid-otc`, and its identity provider is not called `company-idp`.
      otc_domain_name = { value = jsonencode("OTC-EU-DE-00000000001000033025") }
      otc_region      = { value = jsonencode("eu-de") }

      # The meshcloud Entra tenant and its OTC-FEDERATION-OIDC app, which the test deployment uses too.
      identity_provider = { value = jsonencode(jsonencode({
        protocol          = "oidc"
        name              = "likvid-entra"
        email_attribute   = "email"
        oidc_provider_url = "https://login.microsoftonline.com/5f0e994b-6436-4f58-be96-4dc7bebff827/v2.0"
        oidc_client_id    = "7d1e2d5e-e2ef-4aef-a11b-5c6f1371c179"
      })) }

      role_mapping = { value = jsonencode(jsonencode({
        admin  = ["te_admin"]
        user   = ["te_admin"]
        reader = ["readonly"]
      })) }

      services = { value = jsonencode([
        "Network: VPC, subnet and SNAT gateway",
        "OBS Bucket: KMS-encrypted object storage",
        "RDS: managed MySQL, PostgreSQL or SQL Server",
        "CCE: Kubernetes cluster",
      ]) }

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

        # Tags of the management project the architecture creates. `LandingZoneClearance` and
        # `Schutzbedarf` are mandatory on this instance and have no default.
        project = [
          { key = "LandingZoneClearance", values = ["cloud-native"] },
          { key = "Schutzbedarf", values = ["internal"] },
          { key = "environment", values = ["dev"] },
          { key = "ResponsibilityLevel", values = ["Cloud Pro"] },
        ]
        project_owner_tag_key = "projectOwner"
      })) }

      otc_access_key = { sensitive = {
        secret_value   = var.otc_access_key
        secret_version = nonsensitive(sha256(var.otc_access_key))
      } }

      otc_secret_key = { sensitive = {
        secret_value   = var.otc_secret_key
        secret_version = nonsensitive(sha256(var.otc_secret_key))
      } }
    }
  }

  # The definition is `deletion_mode = "DELETE"`, so destroying this block tears down the platform,
  # its management project and the federation it set up.
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
    name = "otc-platform"
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
    display_name                    = "T Cloud Public Platform"
    platform_builder_access_enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
