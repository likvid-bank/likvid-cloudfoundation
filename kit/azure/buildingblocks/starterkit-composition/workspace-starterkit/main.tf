resource "meshstack_project" "project" {
  metadata = {
    name               = var.project_name
    owned_by_workspace = var.workspace_identifier
  }

  spec = {
    display_name = var.project_name

    tags = {
      "environment"          = ["dev"]
      "LandingZoneClearance" = ["sandbox"]
      "Schutzbedarf"         = ["public"]
    }
  }
}

# `meshstack_tenant.spec.platform_ref` needs a platform UUID, which only meshStack can supply, so the
# identifier is resolved into one here. A hardcoded UUID would tie this building block to one meshStack
# installation. The data source's `ref` is shaped for exactly this and passes straight through.
#
# The filter matches the full `<platform>.<location>` identifier, even though the provider documents
# it as matching `metadata.name` — filtering by the bare `azure` returns nothing. `one()` makes the
# module fail loudly if the filter ever stops matching exactly one platform.
data "meshstack_platforms" "azure" {
  identifier = "azure.meshcloud-azure-dev"
}

resource "meshstack_tenant" "azure" {
  metadata = {
    owned_by_workspace = var.workspace_identifier
    owned_by_project   = meshstack_project.project.metadata.name
  }

  spec = {
    platform_ref     = one(data.meshstack_platforms.azure.platforms).ref
    landing_zone_ref = { name = "likvid-azure-sandbox" }
  }
}

data "meshstack_workspace" "this" {
  metadata = {
    name = var.workspace_identifier
  }
}

resource "meshstack_building_block" "repo" {
  spec = {
    building_block_definition_version_ref = {
      # v13 of `GitHub Repository`, the version this module has always ordered.
      uuid = "2a17061b-e0c6-400d-a589-4597c44ee84a"
    }

    display_name = "GitHub Repo ${var.repo_name}"
    target_ref   = data.meshstack_workspace.this.ref

    inputs = {
      repo_name      = { value = jsonencode(var.repo_name) }
      template_owner = { value = jsonencode("likvid-bank") }
      template_repo  = { value = jsonencode("starterkit-template-azure-static-website") }
      use_template   = { value = jsonencode(true) }
    }
  }
}


resource "time_sleep" "wait" {
  depends_on = [meshstack_building_block.repo]

  create_duration = "2m"
}

resource "meshstack_building_block" "pre_github_actions_terraform_setup" {
  depends_on = [time_sleep.wait]

  spec = {
    building_block_definition_version_ref = {
      # v1, the only version of `Azure Subscription GitHub Actions Connector - Role Assignments`.
      uuid = "b31764b8-989c-4bcc-9d61-1cb2fdf50a16"
    }

    display_name = "Pre GitHub Actions Terraform Setup"
    target_ref   = meshstack_tenant.azure.ref
    inputs       = {}
  }
}


resource "meshstack_building_block" "github_actions_terraform_setup" {
  spec = {
    building_block_definition_version_ref = {
      # v13 of `GitHub Actions Connector - Azure Subscription`.
      uuid = "4e211a5b-ffcc-4c46-9567-e5360806be80"
    }

    display_name               = "GitHub Actions Terraform Setup"
    target_ref                 = meshstack_tenant.azure.ref
    parent_building_block_refs = [meshstack_building_block.pre_github_actions_terraform_setup.ref]

    inputs = {
      repo_name = { value = jsonencode(var.project_name) }
    }
  }
}

