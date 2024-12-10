## Platform Team

locals {
  sap-core-platform = [
    "fnowarre@meshcloud.io",
    "ckraus@meshcloud.io"
  ]
  # m25-online-banking-application = [
  # "likvid-anna@meshcloud.io"]
}

resource "meshstack_project" "sap_core_platform" {
  provider = meshstack.sap_core_platform
  metadata = {
    name               = "sapbtp-subaccount-prod"
    owned_by_workspace = "sap-core-platform"
  }
  spec = {
    display_name              = "SAP Subaccount"
    payment_method_identifier = "sap-core"
    tags = {
      "environment"          = ["prod"]
      "confidentiality"      = ["internal"]
      "LandingZoneClearance" = ["cloud-native"]
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
    owned_by_workspace = terraform_data.meshobjects_import["workspaces/sap-core-platform.yml"].output.metadata.name
    name               = meshstack_project.sap_core_platform.metadata.name
  }

  subject = {
    name = each.key
  }
}

# resource "meshstack_tenant" "sap_core_platform" {
#   provider = meshstack.sap_core_platform
#   metadata = {
#     platform_identifier = "meshcloud-sapbtp-dev.sapbtp"
#     owned_by_project    = meshstack_project.sap_core_platform.metadata.name
#     owned_by_workspace  = terraform_data.meshobjects_import["workspaces/sap-core-platform.yml"].output.metadata.name
#   }
#   spec = {
#     landing_zone_identifier = "meshcloud-sapbtp-dev"
#   }
# }

# resource "meshstack_buildingblock" "sap_core_platform_subaccount" {
#   metadata = {
#     definition_uuid    = ""
#     definition_version = 18
#     tenant_identifier  = "${meshstack_project.m25_online_banking_app.metadata.owned_by_workspace}.${meshstack_project.m25_online_banking_app.metadata.name}.${meshstack_tenant.m25_online_banking_app_docs_repo.metadata.platform_identifier}"
#   }

#   spec = {
#     display_name = "my-buildingblock"

#     inputs = {
#       name = { value_string = "my-name" }
#       size = { value_int = 16 }
#     }
#   }
# }
