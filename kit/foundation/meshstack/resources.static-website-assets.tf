## Platform Team

locals {
  m25-platform-team = [
    "malhussan@meshcloud.io",
    "partner@meshcloud.io"
  ]
  m25-online-banking-application-team = ["partner@meshcloud.io"]
}

resource "meshstack_project" "static-website-assets" {
  provider = meshstack.static_website_assets
  metadata = {
    name               = "static-website-assets-dev"
    owned_by_workspace = "m25-platform"
  }
  spec = {
    display_name              = "Static Website Assets"
    payment_method_identifier = "m25-bu"
    tags = {
      "environment"     = ["dev"]
      "confidentiality" = ["Public"]
    }
  }
}

resource "meshstack_tenant" "static-website-assets" {
  provider = meshstack.static_website_assets
  metadata = {
    owned_by_project    = meshstack_project.static-website-assets.metadata.name
    owned_by_workspace  = "m25-platform"
    platform_identifier = "aws.aws-meshstack-dev"
  }
  spec = {
    landing_zone_identifier = "demo-day"
  }
}

resource "meshstack_project_user_binding" "static_website_assets_project_admins" {
  provider = meshstack.static_website_assets
  for_each = toset(local.m25-platform-team)

  metadata = {
    name = "static_website_assets_${each.key}"
  }

  role_ref = {
    name = "Project Admin"
  }

  target_ref = {
    owned_by_workspace = "m25-platform"
    name               = meshstack_project.static-website-assets.metadata.name
  }

  subject = {
    name = each.key
  }
}

## Application Team

resource "meshstack_project" "m25_online_banking_app" {
  provider = meshstack.online_banking_app
  metadata = {
    name               = "online-banking-app-dev"
    owned_by_workspace = terraform_data.meshobjects_import["workspaces/m25-online-banki.yml"].output.metadata.name
  }
  spec = {
    display_name              = "Online Banking App"
    payment_method_identifier = "online"
    tags = {
      "environment"     = ["dev"]
      "confidentiality" = ["Public"]
    }
  }
}

resource "meshstack_tenant" "m25_online_banking_app" {
  provider = meshstack.online_banking_app
  metadata = {
    platform_identifier = "aws.aws-meshstack-dev"
    owned_by_project    = meshstack_project.m25_online_banking_app.metadata.name
    owned_by_workspace  = terraform_data.meshobjects_import["workspaces/m25-online-banki.yml"].output.metadata.name
  }
  spec = {
    landing_zone_identifier = "demo-day"
  }
}

resource "meshstack_project_user_binding" "m25_online_banking_app_admins" {
  provider = meshstack.online_banking_app
  for_each = toset(local.m25-online-banking-application-team)

  metadata = {
    name = "online_banking_app_${each.key}"
  }

  role_ref = {
    name = "Project Admin"
  }

  target_ref = {
    owned_by_workspace = terraform_data.meshobjects_import["workspaces/m25-online-banki.yml"].output.metadata.name
    name               = meshstack_project.m25_online_banking_app.metadata.name
  }

  subject = {
    name = each.key
  }
}

resource "meshstack_buildingblock" "m25_online_banking_app_docs" {
  provider = meshstack.online_banking_app
  metadata = {
    definition_uuid    = "cfbcc75f-65fd-41d8-9a69-b0d5e7e85237"
    definition_version = 6
    tenant_identifier  = "${meshstack_project.m25_online_banking_app.metadata.owned_by_workspace}.${meshstack_project.m25_online_banking_app.metadata.name}.${meshstack_tenant.m25_online_banking_app.metadata.platform_identifier}"
  }
  spec = {
    display_name = "Online Banking App Documentation"
    inputs = {
      file    = { value_string = "buckets/onlinebanking-docs" }
      content = { value_string = "malhussan@meshcloud.io fnowarre@meshcloud.io hdettmer@meshcloud.io rbausinger@meshcloud.io" }
    }
  }
}
