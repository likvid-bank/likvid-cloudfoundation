## Platform Team

locals {
  sap-core-platform = [
    "fnowarre@meshcloud.io",
    "ckraus@meshcloud.io"
  ]
}

resource "meshstack_project" "sap_core_platform" {
  provider = meshstack.sap_core_platform
  metadata = {
    name               = "sap-buildingblocks-dev"
    owned_by_workspace = terraform_data.meshobjects_import["workspaces/sap-core-platform.yml"].output.metadata.name
  }
  spec = {
    display_name              = "sap-buildingblocks-dev"
    payment_method_identifier = "sap-core"
    tags = {
      "environment"          = ["dev"]
      "Schutzbedarf"         = ["internal"]
      "LandingZoneClearance" = ["sap"]
      "projectOwner"         = ["Anna Admin"]
    }
  }
}

resource "meshstack_project_user_binding" "sap_core_platform_project_admins" {
  provider = meshstack.sap_core_platform
  for_each = toset(local.sap-core-platform)

  metadata = {
    name = "sap_core_platform_${each.key}"
  }

  role_ref = {
    name = "Project Admin"
  }

  target_ref = {
    owned_by_workspace = meshstack_project.sap_core_platform.metadata.owned_by_workspace
    name               = meshstack_project.sap_core_platform.metadata.name
  }

  subject = {
    name = each.key
  }
}
