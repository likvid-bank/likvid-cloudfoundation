locals {
  # Create a purely alphanumeric identifier from the display name
  # Remove special characters, convert to lowercase, and replace spaces/hyphens with nothing
  identifier = lower(replace(replace(var.name, "/[^a-zA-Z0-9\\s\\-\\_]/", ""), "/[\\s\\-\\_]+/", "-"))

  # full meshPlatform identifier (`<platform>.<location>`) the dev/prod tenants live on
  aks_platform_identifier = "aks.meshcloud-azure-dev"
}

resource "meshstack_project" "dev" {
  metadata = {
    name               = "${local.identifier}-dev"
    owned_by_workspace = var.workspace_identifier
  }
  spec = {
    display_name = "${var.name} Dev"
    tags = {
      "environment"          = ["dev"]
      "LandingZoneClearance" = ["container-platform"]
      "Schutzbedarf"         = ["public"]
    }
  }
}

resource "meshstack_project" "prod" {
  metadata = {
    name               = "${local.identifier}-prod"
    owned_by_workspace = var.workspace_identifier
  }
  spec = {
    display_name = "${var.name} Prod"
    tags = {
      "environment"          = ["prod"]
      "LandingZoneClearance" = ["container-platform"]
      "Schutzbedarf"         = ["public"]
    }
  }
}

resource "meshstack_project_user_binding" "creator_dev_admin" {
  count = var.creator.type == "User" && var.creator.username != null ? 1 : 0

  metadata = {
    name = uuid()
  }

  role_ref = {
    name = "Project Admin"
  }

  target_ref = {
    owned_by_workspace = var.workspace_identifier
    name               = meshstack_project.dev.metadata.name
  }

  subject = {
    name = var.creator.username
  }
}

resource "meshstack_project_user_binding" "creator_prod_admin" {
  count = var.creator.type == "User" && var.creator.username != null ? 1 : 0

  metadata = {
    name = uuid()
  }

  role_ref = {
    name = "Project Admin"
  }

  target_ref = {
    owned_by_workspace = var.workspace_identifier
    name               = meshstack_project.prod.metadata.name
  }

  subject = {
    name = var.creator.username
  }
}

# `meshstack_tenant.spec.platform_ref` needs a platform UUID, which only meshStack can supply, so the
# identifier is resolved into one here. A hardcoded UUID would tie this building block to one
# meshStack installation. The data source's `ref` is shaped for exactly this and passes straight
# through.
#
# The filter matches the full `<platform>.<location>` identifier, even though the provider documents
# it as matching `metadata.name` — filtering by the bare `aks` returns nothing. `one()` makes the
# building block fail loudly if the filter ever stops matching exactly one platform.
data "meshstack_platforms" "aks" {
  identifier = local.aks_platform_identifier
}

moved {
  from = meshstack_tenant_v4.dev
  to   = meshstack_tenant.dev
}

resource "meshstack_tenant" "dev" {
  metadata = {
    owned_by_workspace = var.workspace_identifier
    owned_by_project   = meshstack_project.dev.metadata.name
  }

  spec = {
    platform_ref     = one(data.meshstack_platforms.aks.platforms).ref
    landing_zone_ref = { name = "likvid-aks-dev" }
  }
}

moved {
  from = meshstack_tenant_v4.prod
  to   = meshstack_tenant.prod
}

resource "meshstack_tenant" "prod" {
  metadata = {
    owned_by_workspace = var.workspace_identifier
    owned_by_project   = meshstack_project.prod.metadata.name
  }

  spec = {
    platform_ref     = one(data.meshstack_platforms.aks.platforms).ref
    landing_zone_ref = { name = "likvid-aks-prod" }
  }
}

resource "meshstack_building_block_v2" "repo" {
  spec = {
    building_block_definition_version_ref = {
      uuid = "4a09ae7f-df0b-4f24-9704-1b5fed0437f6"
    }

    display_name = "likvid-bank/${local.identifier}"
    target_ref = {
      kind       = "meshWorkspace"
      identifier = var.workspace_identifier
    }

    inputs = {
      repo_name = {
        value_string = local.identifier
      }
      repo_owner = {
        value_string = "null"
      }
      use_template = {
        value_bool = true
      }
      template_owner = {
        value_string = "likvid-bank"
      }
      template_repo = {
        value_string = "aks-starterkit-template"
      }
    }
  }
}

# takes a while until github repo and aks namespace are ready
resource "time_sleep" "wait_45_seconds" {
  depends_on = [meshstack_building_block_v2.repo]

  create_duration = "45s"
}

# Fetch the GitHub building block after creation to get outputs
data "meshstack_building_block_v2" "repo_data" {
  depends_on = [time_sleep.wait_45_seconds]

  metadata = {
    uuid = meshstack_building_block_v2.repo.metadata.uuid
  }
}

# We need to fetch both dev&prod tenant data after creation to get the platform tenant ID
data "meshstack_tenant" "aks-dev" {
  depends_on = [time_sleep.wait_45_seconds]

  metadata = {
    owned_by_workspace  = meshstack_tenant.dev.metadata.owned_by_workspace
    owned_by_project    = meshstack_tenant.dev.metadata.owned_by_project
    platform_identifier = local.aks_platform_identifier
  }
}

data "meshstack_tenant" "aks-prod" {
  depends_on = [time_sleep.wait_45_seconds]

  metadata = {
    owned_by_workspace  = meshstack_tenant.prod.metadata.owned_by_workspace
    owned_by_project    = meshstack_tenant.prod.metadata.owned_by_project
    platform_identifier = local.aks_platform_identifier
  }
}

resource "meshstack_building_block_v2" "github_actions_dev" {
  depends_on = [meshstack_building_block_v2.repo, meshstack_tenant.dev]

  spec = {
    building_block_definition_version_ref = {
      uuid = "8e2459bc-4eea-4972-b334-ef1bbc49de9d"
    }

    target_ref = {
      kind = "meshTenant"
      uuid = meshstack_tenant.dev.metadata.uuid
    }

    display_name = "GHA Connector Dev"
    parent_building_blocks = [{
      buildingblock_uuid = meshstack_building_block_v2.repo.metadata.uuid
      definition_uuid    = "8b91fa84-9572-4e1d-a90f-f63f70ffac71"
    }],
    inputs = {
      github_environment_name = {
        value_string = "development"
      }
      additional_environment_variables = {
        value_code = jsonencode({
          "DOMAIN_NAME"        = "${local.identifier}-dev"
          "AKS_NAMESPACE_NAME" = data.meshstack_tenant.aks-dev.spec.platform_tenant_id
        })
      }
    }
  }
}

resource "meshstack_building_block_v2" "github_actions_prod" {
  depends_on = [meshstack_building_block_v2.repo, meshstack_building_block_v2.github_actions_dev]

  spec = {
    building_block_definition_version_ref = {
      uuid = "8e2459bc-4eea-4972-b334-ef1bbc49de9d"
    }

    target_ref = {
      kind = "meshTenant"
      uuid = meshstack_tenant.prod.metadata.uuid
    }

    display_name = "GHA Connector Prod"
    parent_building_blocks = [{
      buildingblock_uuid = meshstack_building_block_v2.repo.metadata.uuid
      definition_uuid    = "8b91fa84-9572-4e1d-a90f-f63f70ffac71"
    }],
    inputs = {
      github_environment_name = {
        value_string = "production"
      }
      additional_environment_variables = {
        value_code = jsonencode({
          "DOMAIN_NAME"        = local.identifier
          "AKS_NAMESPACE_NAME" = data.meshstack_tenant.aks-prod.spec.platform_tenant_id
        })
      }
    }
  }
}

output "dev-link" {
  description = "Link to the dev environment Angular app"
  value       = "https://${local.identifier}-dev.likvid-k8s.msh.host"
}

output "prod-link" {
  description = "Link to the prod environment Angular app"
  value       = "https://${local.identifier}.likvid-k8s.msh.host"
}

output "summary" {
  description = "Summary with next steps and insights into created resources"
  value       = <<-EOT
# AKS Starter Kit

✅ **Your environment is ready!**

This starter kit has set up the following resources in workspace `${var.workspace_identifier}`:

- **GitHub Repository**: [${local.identifier}](<${data.meshstack_building_block_v2.repo_data.status.outputs.repo_html_url.value_string}>)
- **Development Project**: [${meshstack_project.dev.spec.display_name}](/#/w/${var.workspace_identifier}/p/${meshstack_project.dev.metadata.name}/tenants)
  - **AKS Namespace**: [${data.meshstack_tenant.aks-dev.spec.platform_tenant_id}](/#/w/${var.workspace_identifier}/p/${meshstack_project.dev.metadata.name}/i/aks.eu-de-central/overview/azure_kubernetes_service)
- **Production Project**: [${meshstack_project.prod.spec.display_name}](/#/w/${var.workspace_identifier}/p/${meshstack_project.prod.metadata.name}/tenants)
  - **AKS Namespace**: [${data.meshstack_tenant.aks-prod.spec.platform_tenant_id}](/#/w/${var.workspace_identifier}/p/${meshstack_project.prod.metadata.name}/i/aks.eu-de-central/overview/azure_kubernetes_service)

---

## What's Included

Your GitHub repository contains:

- Angular frontend & Node.js backend
- Dockerfiles for both apps
- Kubernetes deployment files
- GitHub Actions CI/CD workflows for AKS

---

## Deployments

Trigger a deployment by:
- Pushing to the **main** branch (deploys to **dev**)
- Merging **main** into **release** via PR (deploys to **prod**)

View deployment status: [GitHub Actions](${data.meshstack_building_block_v2.repo_data.status.outputs.repo_html_url.value_string}/actions/workflows/k8s-deploy.yml)

- **Dev**: [${local.identifier}-dev.likvid-k8s.msh.host](https://${local.identifier}-dev.likvid-k8s.msh.host)
- **Prod**: [${local.identifier}.likvid-k8s.msh.host](https://${local.identifier}.likvid-k8s.msh.host)

---

## Next Steps

### 1. Develop
- Push changes to **main** → deploys to **dev**
- Merge PR from **main → release** → deploys to **prod**

### 2. Monitor
- Check workflow status in the [Actions tab](<${data.meshstack_building_block_v2.repo_data.status.outputs.repo_html_url.value_string}/actions>)

### 3. Access AKS Namespaces
- [Dev Namespace](/#/w/${var.workspace_identifier}/p/${meshstack_project.dev.metadata.name}/i/aks.eu-de-central/overview/azure_kubernetes_service)
- [Prod Namespace](/#/w/${var.workspace_identifier}/p/${meshstack_project.prod.metadata.name}/i/aks.eu-de-central/overview/azure_kubernetes_service)

### 4. Manage Access
- Invite team members via meshStack:
  - [Dev Access](#/w/${var.workspace_identifier}/p/${meshstack_project.dev.metadata.name}/access-management/role-mapping/overview)
  - [Prod Access](#/w/${var.workspace_identifier}/p/${meshstack_project.prod.metadata.name}/access-management/role-mapping/overview)

---

🎉 Happy coding!
EOT
}
