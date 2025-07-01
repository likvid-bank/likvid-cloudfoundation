resource "meshstack_project" "dev" {
  metadata = {
    name               = "${var.project_identifier}-dev"
    owned_by_workspace = var.workspace_identifier
  }
  spec = {
    display_name = "${var.project_identifier}-dev"
    tags = {
      "environment"          = ["dev"]
      "LandingZoneClearance" = ["sap"]
      "Schutzbedarf"         = ["public"]
    }
  }
}

resource "meshstack_project" "prod" {
  metadata = {
    name               = "${var.project_identifier}-prod"
    owned_by_workspace = var.workspace_identifier
  }
  spec = {
    display_name = "${var.project_identifier}-prod"
    tags = {
      "environment"          = ["prod"]
      "LandingZoneClearance" = ["sap"]
      "Schutzbedarf"         = ["public"]

    }
  }
}

resource "meshstack_tenant" "dev" {
  metadata = {
    owned_by_workspace  = var.workspace_identifier
    owned_by_project    = meshstack_project.dev.metadata.name
    platform_identifier = "meshcloud-sapbtp-dev.sapbtp"
  }

  spec = {
    landing_zone_identifier = "sap-composition-dev"
  }
}

resource "meshstack_tenant" "prod" {
  metadata = {
    owned_by_workspace  = var.workspace_identifier
    owned_by_project    = meshstack_project.prod.metadata.name
    platform_identifier = "meshcloud-sapbtp-dev.sapbtp"
  }

  spec = {
    landing_zone_identifier = "sap-composition-prod"
  }
}

resource "meshstack_building_block_v2" "subdirectory" {
  spec = {
    building_block_definition_version_ref = {
      uuid = "6986e518-4028-410b-b943-f0550f95150d"
    }

    display_name = "subdirectory ${var.project_identifier}"
    target_ref = {
      kind       = "meshWorkspace"
      identifier = var.workspace_identifier
    }

    inputs = {
      subfolder          = { value_single_select = var.subfolder }
      project_identifier = { value_string = var.project_identifier }
    }
  }

}

# takes a while until github repo and aks namespace are ready
resource "time_sleep" "wait_30_seconds" {
  depends_on = [meshstack_building_block_v2.subdirectory]

  create_duration = "30s"
}

resource "meshstack_buildingblock" "subaccount_dev" {
  depends_on = [meshstack_building_block_v2.subdirectory, time_sleep.wait_30_seconds]
  metadata = {
    definition_uuid    = "6214c14c-1bd5-46b1-a91f-7b0939219e4b"
    definition_version = 37
    tenant_identifier  = "${meshstack_tenant.dev.metadata.owned_by_workspace}.${meshstack_tenant.dev.metadata.owned_by_project}.${meshstack_tenant.dev.metadata.platform_identifier}"
  }
  spec = {
    display_name = "subaccount ${var.project_identifier}-dev"
    parent_building_blocks = [{
      buildingblock_uuid = meshstack_building_block_v2.subdirectory.metadata.uuid
      definition_uuid    = "4ccc9715-f773-4c23-87e0-ae5fa4899176"
    }]
  }
}

resource "meshstack_buildingblock" "subaccount_prod" {
  depends_on = [meshstack_building_block_v2.subdirectory, time_sleep.wait_30_seconds]
  metadata = {
    definition_uuid    = "6214c14c-1bd5-46b1-a91f-7b0939219e4b"
    definition_version = 37
    tenant_identifier  = "${meshstack_tenant.prod.metadata.owned_by_workspace}.${meshstack_tenant.prod.metadata.owned_by_project}.${meshstack_tenant.prod.metadata.platform_identifier}"
  }
  spec = {
    display_name = "subaccount ${var.project_identifier}-prod"
    parent_building_blocks = [{
      buildingblock_uuid = meshstack_building_block_v2.subdirectory.metadata.uuid
      definition_uuid    = "4ccc9715-f773-4c23-87e0-ae5fa4899176"
    }]
  }
}
