## Platform Team

locals {
  cloudfoundation-team = [
    "fnowarre@meshcloud.io",
    "jrudolph@meshcloud.io"
  ]
}

# a project for hosting cloud tenants to help us test building blocks
resource "meshstack_project" "buildingblocks-testing" {
  metadata = {
    name               = "buildingblocks-testing"
    owned_by_workspace = terraform_data.meshobjects_import["workspaces/cloud-foundation.yml"].output.metadata.name
  }
  spec = {
    display_name = "Building Blocks Testing"
    tags = {
      "environment"          = ["dev"]
      "Schutzbedarf"         = ["public"]
      "LandingZoneClearance" = ["cloud-native"]
    }
  }
}

# The platform refs come from the shared data sources in data.platforms.tf.

resource "meshstack_tenant" "buildingblocks-testing-aws" {
  metadata = {
    owned_by_project   = meshstack_project.buildingblocks-testing.metadata.name
    owned_by_workspace = meshstack_project.buildingblocks-testing.metadata.owned_by_workspace
  }
  spec = {
    platform_ref     = one(data.meshstack_platforms.aws.platforms).ref
    landing_zone_ref = { name = "likvid-aws-prod" } // todo: should have probably used a dev landing zone instead?
  }

  # Destroying or replacing this tenant runs its building block's teardown, which deletes the live AWS
  # account the platform team tests building blocks in. `platform_ref` is RequiresReplace, so a plan can
  # ask for that replacement without anyone intending it — this turns such a plan into an error.
  lifecycle {
    prevent_destroy = true
  }
}

resource "meshstack_tenant" "buildingblocks-testing-gcp" {
  metadata = {
    owned_by_project   = meshstack_project.buildingblocks-testing.metadata.name
    owned_by_workspace = meshstack_project.buildingblocks-testing.metadata.owned_by_workspace
  }
  spec = {
    platform_ref     = one(data.meshstack_platforms.gcp.platforms).ref
    landing_zone_ref = { name = "likvid-gcp-dev" }
  }

  # Destroying or replacing this tenant runs its building block's teardown, which deletes the live GCP
  # project the platform team tests building blocks in. `platform_ref` is RequiresReplace, so a plan can
  # ask for that replacement without anyone intending it — this turns such a plan into an error.
  lifecycle {
    prevent_destroy = true
  }
}
