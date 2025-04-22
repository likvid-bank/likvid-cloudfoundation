resource "meshstack_project" "dev" {
  metadata = {
    name               = "${var.name_prefix}-dev"
    owned_by_workspace = var.workspace_identifier
  }
  spec = {
    display_name = "${var.name_prefix}-dev"
    tags = {
      "environment"          = ["dev"]
      "LandingZoneClearance" = ["container-platform"]
      "Schutzbedarf"         = ["public"]
    }
  }
}

resource "meshstack_project" "prod" {
  metadata = {
    name               = "${var.name_prefix}-prod"
    owned_by_workspace = var.workspace_identifier
  }
  spec = {
    display_name = "${var.name_prefix}-prod"
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
      uuid = "07f93787-64d8-4b53-8e36-ff0f79bcd93c"
    }

    display_name = "GitHub Repo ${var.repo_name}"
    target_ref = {
      kind       = "meshWorkspace"
      identifier = var.workspace_identifier
    }

    inputs = {
      repo_name = {
        value_string = var.repo_name

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
  depends_on = [time_sleep.wait_45_seconds]

  metadata = {
    definition_uuid    = "56e67643-b975-48b6-80c9-6d455bf6d3d2"
    definition_version = 17
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
    definition_version = 17
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
