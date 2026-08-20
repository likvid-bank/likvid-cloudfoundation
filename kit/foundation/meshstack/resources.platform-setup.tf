# This file demonstrates end-to-end platform setup using the meshStack Terraform provider
# It shows how to manage Azure platforms and landing zones as Infrastructure as Code

locals {
  azure_m25_enabled = var.azure_m25_platform != null
}

# Azure M25 Platform
# This platform is managed by the M25 Platform Team and provides Azure services to M25 workspaces
resource "meshstack_platform" "azure_m25" {
  count = local.azure_m25_enabled ? 1 : 0

  metadata = {
    name               = var.azure_m25_platform.platform_identifier
    owned_by_workspace = terraform_data.meshobjects_import["workspaces/m25-platform.yml"].output.metadata.name
  }

  spec = {
    display_name      = var.azure_m25_platform.display_name
    description       = var.azure_m25_platform.description
    endpoint          = "https://portal.azure.com"
    documentation_url = var.azure_m25_platform.documentation_url

    location_ref = {
      name = var.azure_m25_platform.location_ref_name
    }

    availability = {
      restriction       = "PRIVATE"
      publication_state = "UNPUBLISHED"
      restricted_to_workspaces = [
        terraform_data.meshobjects_import["workspaces/m25-platform.yml"].output.metadata.name
      ]
    }

    config = {
      azure = {
        entra_tenant = var.azure_m25_platform.tenant_id

        replication = {
          # The flat `auth_type` + `credentials_auth_client_secret` pair was replaced by a nested
          # `auth` object: `auth.type` is computed from whether `credential` is set, so a null
          # credential means WORKLOAD_IDENTITY and a set one means CREDENTIALS.
          service_principal = {
            client_id = var.azure_m25_platform.replicator_client_id
            object_id = var.azure_m25_platform.replicator_object_id

            auth = {
              credential = var.azure_m25_platform.replicator_auth_type == "CREDENTIALS" ? {
                secret_value = var.azure_m25_platform.replicator_client_secret
              } : null
            }
          }

          provisioning = {
            subscription_owner_object_ids = var.azure_m25_platform.subscription_owner_object_ids

            pre_provisioned = {
              unused_subscription_name_prefix = "unused-"
            }
          }

          subscription_name_pattern = var.azure_m25_platform.subscription_name_pattern
          group_name_pattern        = var.azure_m25_platform.group_name_pattern

          azure_role_mappings = var.azure_m25_platform.azure_role_mappings

          tenant_tags = {
            namespace_prefix = "meshstack_"

            tag_mappers = [
              {
                key           = "wident"
                value_pattern = "$${workspaceIdentifier}"
              },
              {
                key           = "pident"
                value_pattern = "$${projectIdentifier}"
              },
              {
                key           = "costcenter"
                value_pattern = "$${costCenter}"
              }
            ]
          }

          # `user_look_up_strategy` was spelled correctly as `user_lookup_strategy`, and
          # `update_subscription_name` became a required flag; `false` keeps replication from renaming
          # subscriptions that already exist.
          user_lookup_strategy                           = "UserByMailLookupStrategy"
          update_subscription_name                       = false
          skip_user_group_permission_cleanup             = false
          allow_hierarchical_management_group_assignment = false
        }
      }
    }

    contributing_workspaces = []
  }
}

# Azure M25 Sandbox Landing Zone
# This landing zone provides a sandbox environment for M25 developers
resource "meshstack_landingzone" "azure_m25_sandbox" {
  count = local.azure_m25_enabled ? 1 : 0

  # `metadata.owned_by_workspace` became required. It is the same workspace that owns the platform
  # above — the M25 platform team offers this landing zone on its own platform.
  metadata = {
    name               = var.azure_m25_platform.sandbox_landing_zone.identifier
    owned_by_workspace = terraform_data.meshobjects_import["workspaces/m25-platform.yml"].output.metadata.name
    tags = {
      "LandingZoneFamily" = ["sandbox"]
    }
  }

  spec = {
    display_name = var.azure_m25_platform.sandbox_landing_zone.display_name
    description  = var.azure_m25_platform.sandbox_landing_zone.description

    platform_ref = {
      kind = "meshPlatform"
      uuid = meshstack_platform.azure_m25[0].metadata.uuid
    }

    automate_deletion_approval    = var.azure_m25_platform.sandbox_landing_zone.automate_deletion_approval
    automate_deletion_replication = var.azure_m25_platform.sandbox_landing_zone.automate_deletion_replication

    platform_properties = {
      azure = {
        azure_management_group_id = var.azure_m25_platform.sandbox_landing_zone.parent_management_group_id
        azure_role_mappings       = []
      }
    }
    info_link = "https://likvid-bank.github.io/likvid-cloudfoundation/platforms/azure/landingzones/sandbox.html"
  }
}
