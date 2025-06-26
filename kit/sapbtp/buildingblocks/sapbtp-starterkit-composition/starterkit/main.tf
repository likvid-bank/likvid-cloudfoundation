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
      uuid = "9f8bfeb0-262b-44d4-82e4-6fd9ed1dd3b2"
    }

    display_name = "subdirectory ${var.project_identifier}"
    target_ref = {
      kind       = "meshWorkspace"
      identifier = var.workspace_identifier
    }

    inputs = {
      subfolder = { value_single_select = var.subfolder }
    }
  }
}

resource "meshstack_buildingblock" "subaccount_dev" {
  metadata = {
    definition_uuid    = "6214c14c-1bd5-46b1-a91f-7b0939219e4b"
    definition_version = 33
    tenant_identifier  = "${meshstack_tenant.dev.metadata.owned_by_workspace}.${meshstack_tenant.dev.metadata.owned_by_project}.${meshstack_tenant.dev.metadata.platform_identifier}"
  }
  spec = {
    display_name = "subaccount ${var.project_identifier}-dev"
    parent_building_blocks = [{
      buildingblock_uuid = meshstack_building_block_v2.subdirectory.metadata.uuid
      definition_uuid    = meshstack_building_block_v2.subdirectory.spec.building_block_definition_version_ref.uuid
    }]
  }
}

resource "meshstack_buildingblock" "subaccount_prod" {
  metadata = {
    definition_uuid    = "6214c14c-1bd5-46b1-a91f-7b0939219e4b"
    definition_version = 31
    tenant_identifier  = "${meshstack_tenant.prod.metadata.owned_by_workspace}.${meshstack_tenant.prod.metadata.owned_by_project}.${meshstack_tenant.prod.metadata.platform_identifier}"
  }
  spec = {
    display_name = "subaccount ${var.project_identifier}-prod"
    parent_building_blocks = [{
      buildingblock_uuid = meshstack_building_block_v2.subdirectory.metadata.uuid
      definition_uuid    = meshstack_building_block_v2.subdirectory.spec.building_block_definition_version_ref.uuid
    }]
  }
}
