locals {
  # Create a purely alphanumeric identifier from the display name
  # Remove special characters, convert to lowercase, and replace spaces/hyphens with nothing
  identifier = lower(replace(replace(var.name, "/[^a-zA-Z0-9\\s\\-\\_]/", ""), "/[\\s\\-\\_]+/", "-"))
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
  count = var.creator.type == "USER" && var.creator.username != null ? 1 : 0

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
  count = var.creator.type == "USER" && var.creator.username != null ? 1 : 0

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

resource "meshstack_tenant" "dev" {
  metadata = {
    owned_by_workspace  = var.workspace_identifier
    owned_by_project    = meshstack_project.dev.metadata.name
    platform_identifier = "aks.meshcloud-azure-dev"
  }

  spec = {
    landing_zone_identifier = "likvid-aks-dev"
  }
}

resource "meshstack_tenant" "prod" {
  metadata = {
    owned_by_workspace  = var.workspace_identifier
    owned_by_project    = meshstack_project.prod.metadata.name
    platform_identifier = "aks.meshcloud-azure-dev"
  }

  spec = {
    landing_zone_identifier = "likvid-aks-prod"
  }
}

resource "meshstack_building_block_v2" "repo" {
  spec = {
    building_block_definition_version_ref = {
      uuid = "72282779-7926-4110-a184-08af976f82ca"
    }

    display_name = "GitHub Repo ${var.name}"
    target_ref = {
      kind       = "meshWorkspace"
      identifier = var.workspace_identifier
    }

    inputs = {
      repo_name = {
        value_string = local.identifier
      }
      repo_owner = {
        value_string = var.github_username != null ? var.github_username : "null"
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

resource "meshstack_buildingblock" "github_actions_dev" {
  depends_on = [meshstack_building_block_v2.repo, time_sleep.wait_45_seconds]

  metadata = {
    definition_uuid    = "56e67643-b975-48b6-80c9-6d455bf6d3d2"
    definition_version = 25
    tenant_identifier  = "${meshstack_tenant.dev.metadata.owned_by_workspace}.${meshstack_tenant.dev.metadata.owned_by_project}.aks.meshcloud-azure-dev"
  }

  spec = {
    display_name = "GitHub Actions Connector"
    parent_building_blocks = [{
      buildingblock_uuid = meshstack_building_block_v2.repo.metadata.uuid
      definition_uuid    = "8b91fa84-9572-4e1d-a90f-f63f70ffac71"
    }]
  }
}

resource "meshstack_buildingblock" "github_actions_prod" {
  depends_on = [meshstack_building_block_v2.repo, meshstack_buildingblock.github_actions_dev]

  metadata = {
    definition_uuid    = "56e67643-b975-48b6-80c9-6d455bf6d3d2"
    definition_version = 25
    tenant_identifier  = "${meshstack_tenant.prod.metadata.owned_by_workspace}.${meshstack_tenant.prod.metadata.owned_by_project}.aks.meshcloud-azure-dev"
  }

  spec = {
    display_name = "GitHub Actions Connector"
    parent_building_blocks = [{
      buildingblock_uuid = meshstack_building_block_v2.repo.metadata.uuid
      definition_uuid    = "8b91fa84-9572-4e1d-a90f-f63f70ffac71"
    }],
    inputs = {
      branch = {
        value_string = "release"
      }
    }
  }
}

output "summary" {
  description = "Summary with next steps and insights into created resources"
  value       = <<-EOT
# AKS Starter Kit

✅ **Your environment is ready!**

This module has successfully created the following resources for your application in workspace `${var.workspace_identifier}`:

-  **GitHub Repository**: <a href="${data.meshstack_building_block_v2.repo_data.status.outputs.repo_html_url.value_string}" target="_blank">${local.identifier}</a>
-  **Development Project**: <a href="/#/w/${var.workspace_identifier}/p/${meshstack_project.dev.metadata.name}/tenants" target="_blank">${meshstack_project.dev.spec.display_name}</a>
   - **AKS Namespace**: <a href="/#/w/${var.workspace_identifier}/p/${meshstack_project.dev.metadata.name}/i/aks.meshcloud-azure-dev/overview/azure_kubernetes_service" target="_blank">${meshstack_tenant.dev.metadata.owned_by_workspace}.${meshstack_tenant.dev.metadata.owned_by_project}.aks.meshcloud-azure-dev</a>
     - **GitHub Actions Connector**
- **Production Project**: <a href="/#/w/${var.workspace_identifier}/p/${meshstack_project.prod.metadata.name}/tenants" target="_blank">${meshstack_project.prod.spec.display_name}</a>
  - **AKS Namespace**: <a href="/#/w/${var.workspace_identifier}/p/${meshstack_project.prod.metadata.name}/i/aks.meshcloud-azure-dev/overview/azure_kubernetes_service" target="_blank">${meshstack_tenant.prod.metadata.owned_by_workspace}.${meshstack_tenant.prod.metadata.owned_by_project}.aks.meshcloud-azure-dev</a>
    - **GitHub Actions Connector**

## Next Steps

Your GitHub repository has been created and is automatically connected to both your development and production AKS namespaces through GitHub Actions.
The GitHub Actions pipeline deploys the docker container (Dockerfile in your repository) from the repository to the respective AKS namespaces.

### Deploy Your Application
1. **Push your application code** including the required Dockerfile to the created GitHub repository main branch
2. **Your app will be deployed automatically** to the development AKS namespace via GitHub Actions when a commit is pushed to the main branch
3. **To deploy to production**, create a Pull Request to merge the main branch into the release branch and merge the Pull Request.
The GitHub Actions workflow will automatically deploy the application to the production AKS namespace.
4. **Monitor deployments** in the <a href="${data.meshstack_building_block_v2.repo_data.status.outputs.repo_html_url.value_string}/actions" target="_blank">GitHub Actions tab</a> of your repository

### Access Your AKS Namespaces
You can find instructions how to access your AKS namespaces via the meshstack UI:

<a href="/#/w/${var.workspace_identifier}/p/${meshstack_project.dev.metadata.name}/i/aks.meshcloud-azure-dev/overview/azure_kubernetes_service" target="_blank">Development AKS Namespace</a> | <a href="/#/w/${var.workspace_identifier}/p/${meshstack_project.prod.metadata.name}/i/aks.meshcloud-azure-dev/overview/azure_kubernetes_service" target="_blank">Production AKS Namespace</a>

### User Permissions
- **You have access** to both development and production projects in meshStack and therefore also to the respective AKS namespaces.
- **Invite team members** to collaborate by adding them to the respective projects
  - User Management: <a href="/#/w/${var.workspace_identifier}/p/${meshstack_project.dev.metadata.name}/access-management/role-mapping" target="_blank">Development project</a> |
  <a href="/#/w/${var.workspace_identifier}/p/${meshstack_project.prod.metadata.name}/access-management/role-mapping" target="_blank">Production project</a>
- **Access to the GitHub repository** must be managed directly in GitHub. ${var.github_username != null ? "**${var.github_username} has admin access** to the created GitHub repository." : ""} Depending on your organization policies, all organization members may
have access to the repository or you have to add every contributor individually.

Happy coding! 🎉
EOT
}

output "github_repo_url" {
  description = "URL of the created GitHub repository"
  value       = data.meshstack_building_block_v2.repo_data.status.outputs.repo_html_url.value_string
}
