# A second, throwaway instance of the STACKIT landing zone for the agentic demo. An agent proposes a
# change to the architecture as a commit, and a platform engineer approves the resulting run in
# meshStack. Only meshStack holds the STACKIT credentials, the agent never sees them.

locals {
  # Created in meshPanel, not in code.
  workspace = "agentic-platform"
}

module "this" {
  source = "./stackit-landingzone"

  meshstack = {
    owning_workspace_identifier = local.workspace
  }

  hub                   = var.hub
  buildingblock_git_ref = var.buildingblock_git_ref

  approval_policies = {
    manual_triggers = true
    version_upgrade = true
  }

  # A demo instance: the platform identifier gets a random suffix and nothing is protected against
  # deletion.
  playground_mode = true
}

resource "meshstack_building_block" "this" {
  spec = {
    building_block_definition_version_ref = module.this.building_block_definition.version_ref

    display_name = "Agentic STACKIT Landing Zone"
    target_ref   = { kind = "meshWorkspace", name = local.workspace }

    # A version upgrade is how a proposed change reaches the cloud, so it waits for an approval.
    approval_policies = {
      any_input_changes  = true
      manual_triggers    = true
      user_input_changes = true
      version_upgrade    = true
    }

    inputs = {
      platform_identifier = { value = jsonencode("agentic-stackit") }
      use_global_location = { value = jsonencode(true) }

      stackit_org         = { value = jsonencode("05d7eb3f-f875-4bcd-ad0d-a07d62787f21") }
      stackit_owner_email = { value = jsonencode("stackit@meshcloud.io") }

      # The same tags as the live landingzone unit, which explains why each one is needed.
      tags = { value = jsonencode(jsonencode({
        landingzone = {
          LandingZoneFamily = ["cloud-native"]
          environment       = ["dev", "qa", "test", "prod"]
          confidentiality   = ["internal", "public"]
        }

        building_block = {
          LandingZoneClearance = ["cloud-native"]
        }

        project = {
          LandingZoneClearance = ["cloud-native"]
          Schutzbedarf         = ["internal"]
          environment          = ["dev"]
          ResponsibilityLevel  = ["Cloud Pro"]
        }
        project_owner_tag_key = "projectOwner"
      })) }

      # No `network`: a second hub network area in the same organization needs its own free address
      # plan, and adding one is a good change for the agent to propose.

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
