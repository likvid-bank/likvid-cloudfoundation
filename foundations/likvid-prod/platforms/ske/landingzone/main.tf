module "this" {
  source = "github.com/meshcloud/meshstack-hub//reference-architectures/stackit-kubernetes?ref=${var.hub.git_ref}"

  meshstack = {
    owning_workspace_identifier = "stackit-ske-plat"
  }

  hub = {
    git_ref   = var.hub.git_ref
    bbd_draft = var.hub.bbd_draft
  }

  playground_mode = true
}

# Deployed by hand before this unit existed.
import {
  to = module.this.meshstack_building_block_definition.this
  id = "ac8a784f-97ad-4670-bee4-7345776699a8"
}

# Ordered by hand before this unit existed.
import {
  to = meshstack_building_block.this
  id = "429d067a-9e89-42d4-8180-e3827feafeae"
}

resource "meshstack_building_block" "this" {
  wait_for_completion = true

  lifecycle {
    postcondition {
      condition     = self.status.status == "SUCCEEDED"
      error_message = "Building block ${self.metadata.uuid} is ${self.status.status}, not SUCCEEDED. See its run in meshPanel."
    }
  }

  spec = {
    building_block_definition_version_ref = module.this.building_block_definition.version_ref

    display_name = "STACKIT Kubernetes Platform"
    target_ref = {
      kind = "meshWorkspace"
      name = "stackit-ske-plat"
    }

    # The CODE inputs keep the text they were ordered with. Reformatting them counts as an input change
    # and starts a run.
    inputs = {
      platform_identifier       = { value = jsonencode("ske-platform") }
      payment_method_identifier = { value = jsonencode("stackit-ske-platform") }
      use_global_location       = { value = jsonencode(true) }
      landingzone_variant       = { value = jsonencode("default") }
      dns_parent_domain         = { value = jsonencode("stackit.run") }
      ai_model                  = { value = jsonencode("openai/gpt-oss-120b") }

      harbor_username = { value = jsonencode("robot$ske-platform-thfp14-se7l+bootstrap") }

      starterkit_app_name        = { value = jsonencode("ai-summarizer") }
      starterkit_repo_clone_addr = { value = jsonencode("https://github.com/likvid-bank/starterkit-template-stackit-ai-summarizer.git") }

      # Copied from the summary of the STACKIT Landing Zone building block in likvid-stackit.
      landingzone = { value = jsonencode(chomp(<<-EOT
        {
          platform_ref = { uuid = "72dcc8ad-a33f-47dd-9d21-dd0a91d36f9e", kind = "meshPlatform" }
          landingzone_refs = {
            default = { name = "likvid-stackit-default", kind = "meshLandingZone" }
            networked = { name = "likvid-stackit-networked", kind = "meshLandingZone" }
          }
          service_account_bbd_version_ref            = { uuid = "e16614d8-48cf-4f85-b625-22baddc3831d" }
          service_account_federation_bbd_version_ref = { uuid = "ee4b503c-6b5e-4299-8ea8-7964d4a68989" }
        }
        EOT
      )) }

      tags = { value = jsonencode(chomp(<<-EOT
        {
          "landingzone": {
            "LandingZoneFamily": ["cloud-native"]
          },
          "building_block": {
            "LandingZoneClearance": ["cloud-native"]
          },
          "project": {
            "LandingZoneClearance": ["cloud-native"],
            "ResponsibilityLevel": ["Cloud Pro"],
            "Schutzbedarf": ["internal"],
            "environment": ["prod"]
          },
          "project_owner_tag_key": "projectOwner"
        }
        EOT
      )) }

      stages = { value = jsonencode(chomp(<<-EOT
        {
          "dev": {
            "landingzone": { "confidentiality": ["internal"] },
            "project": { "Schutzbedarf": ["internal"] }
          },
          "prod": {
            "landingzone": { "confidentiality": ["public"] },
            "project": { "Schutzbedarf": ["public"] }
          }
        }
        EOT
      )) }
    }
  }
}
