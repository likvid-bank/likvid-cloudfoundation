# The definition "PostgreSQL Database" for the namespaces of the SKE platform: a database on the
# shared PostgreSQL instance of the tenant's landing zone and its credentials as a Secret in the
# namespace. The code is kit/ske/buildingblocks/postgres-database/buildingblock.

locals {
  owning_workspace_identifier = "devops-platform"
  ske_cluster_name            = "starterkit"

  # The ske/platform unit orders "Shared PostgreSQL <stage>" on its own tenant.
  landing_zone_stages = {
    ske-namespace-dev  = "dev"
    ske-namespace-prod = "prod"
  }
}

data "meshstack_tenant" "platform" {
  metadata = {
    owned_by_workspace  = local.owning_workspace_identifier
    owned_by_project    = "stackit-kubernetes-platform"
    platform_identifier = "likvid-stackit.global"
  }
}

data "meshstack_building_blocks" "automation_identity" {
  tenant_uuid = data.meshstack_tenant.platform.metadata.uuid
  name        = "Automation Identity"
}

data "meshstack_building_blocks" "shared_postgres" {
  for_each = local.landing_zone_stages

  tenant_uuid = data.meshstack_tenant.platform.metadata.uuid
  name        = "Shared PostgreSQL ${each.value}"
}

# Registered by the STACKIT Landing Zone in ../../../stackit/landingzone, owned by stackit-platform.
data "meshstack_building_block_definition" "service_account_federation" {
  metadata = { uuid = "9dc16888-9fd9-43b7-9ebc-98261043b08f" }
}

locals {
  stackit_project_id = data.meshstack_tenant.platform.spec.platform_tenant_id

  automation_identity   = one(data.meshstack_building_blocks.automation_identity.building_blocks)
  service_account_email = jsondecode(local.automation_identity.status.outputs["service_account_email"].value)

  instance_ids = {
    for landing_zone, blocks in data.meshstack_building_blocks.shared_postgres :
    landing_zone => jsondecode(one(blocks.building_blocks).status.outputs["instance_id"].value)
  }
}

# Valid until Friday 2026-11-27. Renew with `terragrunt apply -replace=stackit_ske_kubeconfig.admin`,
# which changes the definition's input and so needs a draft version.
resource "stackit_ske_kubeconfig" "admin" {
  project_id   = local.stackit_project_id
  cluster_name = local.ske_cluster_name
  expiration   = 7 * 24 * 3600
}

module "runner" {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/meshstack/runner-identity?ref=${var.meshstack_hub_git_ref}"

  cloud      = "azure"
  runner_ref = { kind = "meshBuildingBlockRunner", uuid = "98520496-627d-43e6-82da-ce499179ff3f" }
}

resource "meshstack_building_block_definition" "this" {
  metadata = {
    owned_by_workspace = local.owning_workspace_identifier
  }

  spec = {
    display_name     = "PostgreSQL Database"
    symbol           = "https://raw.githubusercontent.com/meshcloud/meshstack-hub/${var.meshstack_hub_git_ref}/modules/stackit/postgres/buildingblock/logo.png"
    description      = "A PostgreSQL database for your namespace on the platform's shared instance, with the credentials delivered as a Kubernetes Secret."
    target_type      = "TENANT_LEVEL"
    run_transparency = true
    readme           = file("${path.module}/definition_readme.md")

    supported_platforms = [
      for landing_zone in keys(local.landing_zone_stages) : { kind = "meshLandingZone", name = landing_zone }
    ]
  }

  version_spec = {
    draft         = var.draft
    deletion_mode = "DELETE"
    runner_ref    = module.runner.ref

    implementation = {
      terraform = {
        terraform_version              = "1.12.5"
        repository_url                 = "https://github.com/likvid-bank/likvid-cloudfoundation.git"
        repository_path                = "kit/ske/buildingblocks/postgres-database/buildingblock"
        ref_name                       = var.building_block_git_ref
        use_mesh_http_backend_fallback = true
      }
    }

    inputs = {
      workspace_identifier = {
        display_name    = "Workspace"
        description     = "Database and user are named `<workspace>_<project>`, with `_` for `-`."
        type            = "STRING"
        assignment_type = "WORKSPACE_IDENTIFIER"
      }

      project_identifier = {
        display_name    = "Project"
        description     = "Database and user are named `<workspace>_<project>`, with `_` for `-`."
        type            = "STRING"
        assignment_type = "PROJECT_IDENTIFIER"
      }

      namespace = {
        display_name    = "Namespace"
        description     = "Kubernetes namespace of the tenant, which receives the Secret."
        type            = "STRING"
        assignment_type = "PLATFORM_TENANT_ID"
      }

      landing_zone_identifier = {
        display_name    = "Landing Zone"
        description     = "Landing zone of the tenant. It selects the shared instance."
        type            = "STRING"
        assignment_type = "LANDING_ZONE_IDENTIFIER"
      }

      instance_ids = {
        display_name    = "Shared Instances"
        description     = "ID of the shared PostgreSQL Flex instance per landing zone identifier."
        type            = "CODE"
        assignment_type = "STATIC"
        argument        = jsonencode(jsonencode(local.instance_ids))
      }

      stackit_project_id = {
        display_name    = "STACKIT Project ID"
        description     = "STACKIT project of the shared instances."
        type            = "STRING"
        assignment_type = "STATIC"
        argument        = jsonencode(local.stackit_project_id)
      }

      "kubeconfig.yaml" = {
        display_name    = "kubeconfig.yaml"
        description     = "Admin kubeconfig of the cluster `${local.ske_cluster_name}`."
        type            = "FILE"
        assignment_type = "STATIC"
        sensitive = {
          argument = {
            secret_value   = "data:application/yaml;base64,${base64encode(stackit_ske_kubeconfig.admin.kube_config)}"
            secret_version = nonsensitive(sha256(stackit_ske_kubeconfig.admin.kube_config))
          }
        }
      }

      STACKIT_SERVICE_ACCOUNT_EMAIL = {
        display_name    = "STACKIT Service Account Email"
        description     = "The platform's automation service account, which the runs act as via WIF."
        type            = "STRING"
        assignment_type = "STATIC"
        is_environment  = true
        argument        = jsonencode(local.service_account_email)
      }

      STACKIT_USE_OIDC = {
        display_name    = "STACKIT Use OIDC"
        description     = "Enables OIDC-based WIF for the STACKIT provider."
        type            = "STRING"
        assignment_type = "STATIC"
        is_environment  = true
        argument        = jsonencode("1")
      }

      STACKIT_FEDERATED_TOKEN_FILE = {
        display_name    = "STACKIT Federated Token File"
        description     = "Path to the WIF token file injected by meshStack."
        type            = "STRING"
        assignment_type = "STATIC"
        is_environment  = true
        argument        = jsonencode(module.runner.token_path)
      }
    }

    outputs = {
      database = {
        display_name    = "Database"
        type            = "STRING"
        assignment_type = "NONE"
      }

      username = {
        display_name    = "Username"
        type            = "STRING"
        assignment_type = "NONE"
      }

      host = {
        display_name    = "Host"
        type            = "STRING"
        assignment_type = "NONE"
      }

      port = {
        display_name    = "Port"
        type            = "INTEGER"
        assignment_type = "NONE"
      }

      secret_name = {
        display_name    = "Kubernetes Secret"
        type            = "STRING"
        assignment_type = "NONE"
      }

      summary = {
        display_name    = "Summary"
        type            = "STRING"
        assignment_type = "SUMMARY"
      }
    }
  }
}

resource "meshstack_building_block" "federation" {
  wait_for_completion = true

  lifecycle {
    postcondition {
      condition     = self.status.succeeded
      error_message = "Building block ${self.metadata.uuid} did not succeed: health status ${self.status.health_status}, action ${self.status.action}. See its run in meshPanel."
    }
  }

  spec = {
    parent_building_block_refs            = [{ uuid = local.automation_identity.metadata.uuid }]
    building_block_definition_version_ref = data.meshstack_building_block_definition.service_account_federation.version_latest_release
    display_name                          = "PostgreSQL Database Identity Federation"
    target_ref                            = { kind = "meshTenant", uuid = data.meshstack_tenant.platform.metadata.uuid }

    inputs = {
      service_account_email = { value = jsonencode(local.service_account_email) }
      federated_building_block_definitions = {
        value = jsonencode(jsonencode([meshstack_building_block_definition.this.metadata.uuid]))
      }
    }
  }
}

output "building_block_definition" {
  value = {
    uuid        = meshstack_building_block_definition.this.metadata.uuid
    version_ref = meshstack_building_block_definition.this.version_latest
  }
}

output "instance_ids" {
  value = local.instance_ids
}

output "kubeconfig_expires_at" {
  value = stackit_ske_kubeconfig.admin.expires_at
}
