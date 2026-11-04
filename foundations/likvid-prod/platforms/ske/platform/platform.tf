locals {
  version_upgrade_gate = {
    building_block_creation = false
    user_input_changes      = false
    any_input_changes       = false
    manual_triggers         = false
    version_upgrade         = true
  }
}

module "stackit_kubernetes" {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//reference-architectures/stackit-kubernetes?ref=${var.hub_ref}"

  meshstack = { owning_workspace_identifier = local.owning_workspace_identifier }
  hub = {
    git_ref   = var.hub_ref
    bbd_draft = false
  }

  approval_policies = local.version_upgrade_gate
}

resource "meshstack_building_block" "platform" {
  wait_for_completion = true

  lifecycle {
    postcondition {
      condition     = self.status.status == "SUCCEEDED"
      error_message = "Building block ${self.metadata.uuid} ended in ${self.status.status}. See its run in meshPanel."
    }
  }

  spec = {
    building_block_definition_version_ref = module.stackit_kubernetes.building_block_definition.version_ref

    display_name = "STACKIT Kubernetes Platform"
    target_ref = {
      kind = "meshWorkspace"
      name = local.owning_workspace_identifier
    }

    # A replaced tenant deletes the STACKIT project through its "STACKIT Project" building block.
    inputs = {
      landingzone = { value = jsonencode(jsonencode({
        platform_ref = { uuid = local.stackit_platform_uuid }
        landingzone_refs = {
          default = { name = "likvid-stackit-default" }
        }
        service_account_bbd_version_ref            = { uuid = data.meshstack_building_block_definition.service_account.version_latest_release.uuid }
        service_account_federation_bbd_version_ref = { uuid = data.meshstack_building_block_definition.service_account_federation.version_latest_release.uuid }
      })) }
      landingzone_variant = { value = jsonencode("default") }
      platform_identifier = { value = jsonencode("ske-namespace") }
      playground_mode     = { value = jsonencode(false) }
      # The legacy starterkit created its projects without a suffix.
      starterkit_add_random_name_suffix = { value = jsonencode(false) }
      use_global_location               = { value = jsonencode(false) }
      payment_method                    = { value = jsonencode({ kind = "meshPaymentMethod", name = "devops-platform-budget" }) }
      dns_domain                        = { value = jsonencode("likvid.stackit.run") }
      phase2_completed                  = { value = jsonencode(true) }

      starterkit_demo = { value = jsonencode(jsonencode({
        name          = "ai-summarizer"
        template_repo = "https://github.com/likvid-bank/starterkit-template-stackit-ai-summarizer.git"
        ai_model      = "openai/gpt-oss-120b"
      })) }
      overrides = { value = jsonencode(jsonencode({
        project_identifier   = "stackit-kubernetes-platform"
        cluster_name         = "starterkit"
        cluster_issuer_email = "ske@meshcloud.io"
      })) }

      tags = { value = jsonencode(jsonencode({
        project = [
          { key = "environment", values = ["prod"] },
          { key = "LandingZoneClearance", values = ["cloud-native"] },
          { key = "ResponsibilityLevel", values = ["Cloud Pro"] },
          { key = "Schutzbedarf", values = ["public"] },
        ]
        starterkit_project = [
          { key = "LandingZoneClearance", values = ["cloud-native"] },
          { key = "ResponsibilityLevel", values = ["Cloud Pro"] },
        ]
        landingzone               = []
        building_block            = []
        starterkit_building_block = []
        project_owner_tag_key     = "projectOwner"
      })) }
      stages = { value = jsonencode(jsonencode([
        for stage, confidentiality in { dev = "internal", prod = "public" } : {
          name                              = stage
          landingzone = [
            { key = "LandingZoneFamily", values = ["cloud-native"] },
            { key = "environment", values = [stage] },
            { key = "confidentiality", values = [confidentiality] },
          ]
          project = [
            { key = "environment", values = [stage] },
            { key = "Schutzbedarf", values = [confidentiality] },
          ]
        }
      ])) }

      approval_policies = { value = jsonencode(jsonencode(local.version_upgrade_gate)) }
      # Application teams move to the new starterkit version only through a reviewed upgrade.
      starterkit_approval_policies = { value = jsonencode(jsonencode(local.version_upgrade_gate)) }

      imports = { value = jsonencode(jsonencode({
        project = {
          display_name = "STACKIT Kubernetes Platform"
          admin_bindings = {
            "jrudolph@meshcloud.io"   = "49769bdf-cc4a-4bb8-bc55-f62a467147db"
            "hdettmer@meshcloud.io"   = "31633950-03b0-4696-951e-817bc58559c5"
            "jschwandke@meshcloud.io" = "a402c989-6de2-4fde-a884-f40c9c9d566d"
          }
        }
        adopt_ske = true
        git = {
          instance_id          = "c86ade0c-b3b2-4a1a-9f75-3252200a56de"
          instance_name        = "likvid"
          forgejo_organization = "likvid"
        }
        dns = {
          zone_id       = "d9b628aa-7dc5-48d8-913d-939fd54490c4"
          record_set_id = "275662f6-532b-49b1-b7de-4c203bbb3618"
        }
        adopt_ingress = true
        kubernetes_platform = {
          platform_name = "ske-namespace"
          location_name = "sovereign"
          landingzone_names = {
            dev  = "ske-namespace-dev"
            prod = "ske-namespace-prod"
          }
        }
        starterkit_definitions = {
          starterkit        = "1344928d-1d8b-4663-8f65-7b4ef9a80156"
          git_repository    = "aa90a873-9c8d-46c6-b0da-29fead24ee92"
          forgejo_connector = "a3bd1afc-4c69-412b-b575-4c72a2ff2e02"
        }
      })) }
      # Empty since the Forgejo organization is adopted; leaving the input out would keep the stored token.
      import_secrets = {
        sensitive = {
          secret_value   = jsonencode({})
          secret_version = sha256(jsonencode({}))
        }
      }
    }
  }
}
