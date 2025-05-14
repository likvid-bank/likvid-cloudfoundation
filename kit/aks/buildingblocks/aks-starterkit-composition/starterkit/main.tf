resource "meshstack_project" "dev" {
  metadata = {
    name               = "${var.name}-dev"
    owned_by_workspace = var.workspace_identifier
  }
  spec = {
    display_name = "${var.name}-dev"
    tags = {
      "environment"          = ["dev"]
      "LandingZoneClearance" = ["container-platform"]
      "Schutzbedarf"         = ["public"]
    }
  }
}

resource "meshstack_project" "prod" {
  metadata = {
    name               = "${var.name}-prod"
    owned_by_workspace = var.workspace_identifier
  }
  spec = {
    display_name = "${var.name}-prod"
    tags = {
      "environment"          = ["prod"]
      "LandingZoneClearance" = ["container-platform"]
      "Schutzbedarf"         = ["public"]

    }
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
      uuid = "2a17061b-e0c6-400d-a589-4597c44ee84a"
    }

    display_name = "GitHub Repo ${var.name}"
    target_ref = {
      kind       = "meshWorkspace"
      identifier = var.workspace_identifier
    }

    inputs = {
      repo_name = {
        value_string = var.name
      }
      use_template = {
        value_bool = false
      }
      # The API doesn't fetch default values from the BuildingBlock Definition currently
      # This is a workaround to set the an unused value for the template_owner and template_repo inputs
      template_owner = {
        value_string = "null"
      }
      template_repo = {
        value_string = "null"
      }
    }
  }
}

# takes a while until github repo and aks namespace are ready
resource "time_sleep" "wait_45_seconds" {
  depends_on = [meshstack_building_block_v2.repo]

  create_duration = "45s"
}

resource "meshstack_buildingblock" "github_actions_dev" {
  depends_on = [meshstack_building_block_v2.repo, time_sleep.wait_45_seconds]

  metadata = {
    definition_uuid    = "56e67643-b975-48b6-80c9-6d455bf6d3d2"
    definition_version = 19
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
    definition_version = 19
    tenant_identifier  = "${meshstack_tenant.prod.metadata.owned_by_workspace}.${meshstack_tenant.prod.metadata.owned_by_project}.aks.meshcloud-azure-dev"
  }

  spec = {
    display_name = "GitHub Actions Connector"
    parent_building_blocks = [{
      buildingblock_uuid = meshstack_building_block_v2.repo.metadata.uuid
      definition_uuid    = "8b91fa84-9572-4e1d-a90f-f63f70ffac71"
    }]
  }
}
