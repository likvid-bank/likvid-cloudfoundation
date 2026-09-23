# A second, throwaway instance of the STACKIT landing zone for the agentic demo. An agent proposes a
# change to the architecture as a commit, and a platform engineer approves the resulting run in
# meshStack. Runs reach STACKIT through WIF, so nobody holds a STACKIT key, the agent included.

locals {
  # Created in meshPanel, not in code.
  workspace = "agentic-platform"
}

resource "meshstack_building_block" "this" {
  spec = {
    building_block_definition_version_ref = meshstack_building_block_definition.this.version_latest

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
    }
  }
}
