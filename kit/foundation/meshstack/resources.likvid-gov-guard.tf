## Platform Team

locals {
  likvid-gov-guard = [
    "likvid-tom@meshcloud.io",
    "likvid-daniela@meshcloud.io"
  ]
}

resource "meshstack_project" "likvid_gov_guard_dev" {
  provider = meshstack.likvid_gov_guard

  metadata = {
    name               = "likvid-gov-guard-dev"
    owned_by_workspace = terraform_data.meshobjects_import["workspaces/likvid-govguard.yml"].output.metadata.name
  }
  spec = {
    display_name              = "likvid-gov-guard-dev"
    payment_method_identifier = "likvid-gov-guard"
    tags = {
      "environment"          = ["dev"]
      "Schutzbedarf"         = ["Grundschutz-hoch"]
      "LandingZoneClearance" = ["cloud-native"]
    }
  }
}

resource "meshstack_project" "likvid_gov_guard_prod" {
  provider = meshstack.likvid_gov_guard

  metadata = {
    name               = "likvid-gov-guard-prod"
    owned_by_workspace = terraform_data.meshobjects_import["workspaces/likvid-govguard.yml"].output.metadata.name
  }
  spec = {
    display_name              = "likvid-gov-guard-prod"
    payment_method_identifier = "likvid-gov-guard"
    tags = {
      "environment"          = ["prod"]
      "Schutzbedarf"         = ["Grundschutz-hoch"]
      "LandingZoneClearance" = ["cloud-native"]
    }
  }
}

resource "meshstack_project_user_binding" "likvid_gov_guard_dev_project_admins" {
  provider = meshstack.likvid_gov_guard

  for_each = toset(local.likvid-gov-guard)

  metadata = {
    name = "gov_guard_prod_${each.key}"
  }

  role_ref = {
    name = "Project Admin"
  }

  target_ref = {
    owned_by_workspace = meshstack_project.likvid_gov_guard_dev.metadata.owned_by_workspace
    name               = meshstack_project.likvid_gov_guard_dev.metadata.name
  }

  subject = {
    name = each.key
  }
}

resource "meshstack_project_user_binding" "likvid_gov_guard_prod_project_admins" {
  provider = meshstack.likvid_gov_guard

  for_each = toset(local.likvid-gov-guard)

  metadata = {
    name = "gov_guard_dev_${each.key}"
  }

  role_ref = {
    name = "Project Admin"
  }

  target_ref = {
    owned_by_workspace = meshstack_project.likvid_gov_guard_prod.metadata.owned_by_workspace
    name               = meshstack_project.likvid_gov_guard_prod.metadata.name
  }

  subject = {
    name = each.key
  }
}

# resource "meshstack_tenant" "sap_core_platform" {
#   provider = meshstack.likvid_gov_guard

#   metadata = {
#     platform_identifier = "meshcloud-sapbtp-dev.sapbtp"
#     owned_by_project    = meshstack_project.sap_core_platform.metadata.name
#     owned_by_workspace  = meshstack_project.sap_core_platform.metadata.owned_by_workspace
#   }
#   spec = {
#     landing_zone_identifier = "likvid-sapbtp-dev"
#   }
# }
