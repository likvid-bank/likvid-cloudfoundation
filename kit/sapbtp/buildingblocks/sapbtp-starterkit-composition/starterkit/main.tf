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

# `meshstack_tenant.spec.platform_ref` needs a platform UUID, which only meshStack can supply, so the
# identifier is resolved into one here. A hardcoded UUID would tie this building block to one meshStack
# installation. The data source's `ref` is shaped for exactly this and passes straight through.
#
# The filter matches the full `<platform>.<location>` identifier, even though the provider documents
# it as matching `metadata.name` — filtering by the bare `meshcloud-sapbtp-dev` returns nothing. `one()`
# makes the module fail loudly if the filter ever stops matching exactly one platform.
data "meshstack_platforms" "sapbtp" {
  identifier = "meshcloud-sapbtp-dev.sapbtp"
}

resource "meshstack_tenant" "dev" {
  metadata = {
    owned_by_workspace = var.workspace_identifier
    owned_by_project   = meshstack_project.dev.metadata.name
  }

  spec = {
    platform_ref     = one(data.meshstack_platforms.sapbtp.platforms).ref
    landing_zone_ref = { name = "sap-composition-dev" }
  }
}

resource "meshstack_tenant" "prod" {
  metadata = {
    owned_by_workspace = var.workspace_identifier
    owned_by_project   = meshstack_project.prod.metadata.name
  }

  spec = {
    platform_ref     = one(data.meshstack_platforms.sapbtp.platforms).ref
    landing_zone_ref = { name = "sap-composition-prod" }
  }
}

data "meshstack_workspace" "this" {
  metadata = {
    name = var.workspace_identifier
  }
}

resource "meshstack_building_block" "subdirectory" {
  spec = {
    building_block_definition_version_ref = {
      uuid = "2b7f3d16-154c-43e9-9eba-13059fca0dd9"
    }

    display_name = "subdirectory ${var.project_identifier}"
    target_ref   = data.meshstack_workspace.this.ref

    inputs = {
      subfolder          = { value = jsonencode(var.subfolder) }
      project_identifier = { value = jsonencode(var.project_identifier) }
    }
  }
}

moved {
  from = meshstack_building_block_v2.subdirectory
  to   = meshstack_building_block.subdirectory
}

# takes a while until github repo and aks namespace are ready
resource "time_sleep" "wait_30_seconds" {
  depends_on = [meshstack_building_block.subdirectory]

  create_duration = "30s"
}

resource "meshstack_building_block" "subaccount_dev" {
  depends_on = [time_sleep.wait_30_seconds]

  spec = {
    building_block_definition_version_ref = {
      # v44 of `Subaccount`, the version this module has always ordered.
      uuid = "71edbbb6-41b4-4170-a408-6ff34c7000f9"
    }

    display_name = "subaccount ${var.project_identifier}-dev"
    target_ref   = meshstack_tenant.dev.ref

    inputs = {
      subfolder = { value = jsonencode(var.project_identifier) }
    }
  }
}

moved {
  from = meshstack_buildingblock.subaccount_dev
  to   = meshstack_building_block.subaccount_dev
}

resource "meshstack_building_block" "subaccount_prod" {
  depends_on = [time_sleep.wait_30_seconds]

  spec = {
    building_block_definition_version_ref = {
      uuid = "71edbbb6-41b4-4170-a408-6ff34c7000f9"
    }

    display_name = "subaccount ${var.project_identifier}-prod"
    target_ref   = meshstack_tenant.prod.ref

    inputs = {
      subfolder = { value = jsonencode(var.project_identifier) }
    }
  }
}

moved {
  from = meshstack_buildingblock.subaccount_prod
  to   = meshstack_building_block.subaccount_prod
}
