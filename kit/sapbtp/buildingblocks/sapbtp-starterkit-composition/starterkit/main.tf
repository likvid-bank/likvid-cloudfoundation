resource "meshstack_project" "dev" {
  metadata = {
    name               = "${var.name}-dev"
    owned_by_workspace = var.workspace_identifier
  }
  spec = {
    display_name = "${var.name}-dev"
    tags = {
      "environment"          = ["dev"]
      "LandingZoneClearance" = ["sap"]
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

resource "meshstack_buildingblock" "subaccount_dev" {
  metadata = {
    definition_uuid    = "6214c14c-1bd5-46b1-a91f-7b0939219e4b"
    definition_version = 29
    tenant_identifier  = "${meshstack_tenant.dev.metadata.owned_by_workspace}.${meshstack_tenant.dev.metadata.owned_by_project}.${meshstack_tenant.dev.metadata.platform_identifier}"
  }
  spec = {
    display_name = "subaccount ${var.name}-dev"
    inputs = {
      subfolder = { value_single_select = var.subfolder }
    }
  }
}

resource "meshstack_buildingblock" "subaccount_prod" {
  metadata = {
    definition_uuid    = "6214c14c-1bd5-46b1-a91f-7b0939219e4b"
    definition_version = 29
    tenant_identifier  = "${meshstack_tenant.prod.metadata.owned_by_workspace}.${meshstack_tenant.prod.metadata.owned_by_project}.${meshstack_tenant.prod.metadata.platform_identifier}"
  }
  spec = {
    display_name = "subaccount ${var.name}-prod"
    inputs = {
      subfolder = { value_single_select = var.subfolder }
    }
  }
}
