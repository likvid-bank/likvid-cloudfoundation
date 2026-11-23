locals {
  landing_zone_stages = {
    ske-namespace-dev  = "dev"
    ske-namespace-prod = "prod"
  }

  instance_ids = {
    for landing_zone, stage in local.landing_zone_stages :
    landing_zone => jsondecode(meshstack_building_block.instance[stage].status.outputs["instance_id"].value)
    if var.order_instances
  }
}

module "runner" {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/meshstack/runner-identity?ref=${var.hub.git_ref}"

  cloud      = "azure"
  runner_ref = local.runner_ref
}

resource "meshstack_building_block_definition" "connector" {
  metadata = {
    owned_by_workspace = local.owning_workspace_identifier
  }

  spec = {
    display_name     = "Postgres DB"
    symbol           = "https://raw.githubusercontent.com/meshcloud/meshstack-hub/${var.hub.git_ref}/modules/stackit/postgres/buildingblock/logo.png"
    description      = "A PostgreSQL database for your namespace on the platform's shared instance, with the credentials delivered as a Kubernetes Secret."
    target_type      = "TENANT_LEVEL"
    run_transparency = true
    readme           = file("${path.module}/connector_readme.md")

    supported_platforms = [
      for landing_zone in keys(local.landing_zone_stages) : { kind = "meshLandingZone", name = landing_zone }
    ]
  }

  version_spec = {
    draft         = false
    deletion_mode = "DELETE"
    runner_ref    = module.runner.ref

    implementation = {
      terraform = {
        terraform_version = "1.12.5"
        repository_url    = "https://github.com/likvid-bank/likvid-cloudfoundation.git"
        repository_path   = "foundations/likvid-prod/platforms/ske/postgres/buildingblock"
        # A commit, so that blocks on an older version keep the code they were ordered with.
        ref_name                       = "d3b3415e4028d08a862d5f21fe1516ef0f26fc99"
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

      # The code ignores it so far; it shows an input that only prod tenants get.
      enable_audit = {
        display_name    = "Audit logging"
        description     = "Records every change to your tables in an audit trail. Production only."
        type            = "BOOLEAN"
        assignment_type = "USER_INPUT"
        default_value   = jsonencode(false)
        condition       = "input.landing_zone_identifier == \"ske-namespace-prod\""
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

      job_namespace = {
        display_name    = "Job Namespace"
        description     = "Namespace of the platform team the Job that isolates the database runs in, outside the app team's quota."
        type            = "STRING"
        assignment_type = "STATIC"
        argument        = jsonencode(meshstack_tenant.jobs.spec.platform_tenant_id)
      }

      ske_project_id = {
        display_name    = "SKE Project ID"
        description     = "STACKIT project of the SKE cluster the namespaces live on."
        type            = "STRING"
        assignment_type = "STATIC"
        argument        = jsonencode(local.platform_stackit_project_id)
      }

      ske_cluster_name = {
        display_name    = "SKE Cluster Name"
        description     = "Name of the SKE cluster the namespaces live on. The run opens an admin kubeconfig for it."
        type            = "STRING"
        assignment_type = "STATIC"
        argument        = jsonencode(local.ske_cluster_name)
      }

      STACKIT_SERVICE_ACCOUNT_EMAIL = {
        display_name    = "STACKIT Service Account Email"
        description     = "The platform's automation service account, which the runs act as through workload identity federation."
        type            = "STRING"
        assignment_type = "STATIC"
        is_environment  = true
        argument        = jsonencode(local.service_account_email)
      }

      STACKIT_USE_OIDC = {
        display_name    = "STACKIT Use OIDC"
        description     = "Makes the STACKIT provider log in with the runner's OIDC token."
        type            = "STRING"
        assignment_type = "STATIC"
        is_environment  = true
        argument        = jsonencode("1")
      }

      STACKIT_FEDERATED_TOKEN_FILE = {
        display_name    = "STACKIT Federated Token File"
        description     = "Path of the token file the runner writes."
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

