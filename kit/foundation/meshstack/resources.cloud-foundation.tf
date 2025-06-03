## Platform Team

locals {
  cloudfoundation-team = [
    "fnowarre@meshcloud.io",
    "jrudolph@meshcloud.io"
  ]
}

# a project for hosting cloud tenants to help us test building blocks
resource "meshstack_project" "buildingblocks-testing" {
  provider = meshstack.cloudfoundation
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

resource "meshstack_tenant" "buildingblocks-testing-aws" {
  provider = meshstack.cloudfoundation
  metadata = {
    owned_by_project    = meshstack_project.buildingblocks-testing.metadata.name
    owned_by_workspace  = meshstack_project.buildingblocks-testing.metadata.owned_by_workspace
    platform_identifier = "aws.aws-meshstack-dev"
  }
  spec = {
    landing_zone_identifier = "likvid-aws-prod" // todo: should have probably used a dev landing zone instead?
  }
}

resource "meshstack_tenant" "buildingblocks-testing-gcp" {
  provider = meshstack.cloudfoundation
  metadata = {
    owned_by_project    = meshstack_project.buildingblocks-testing.metadata.name
    owned_by_workspace  = meshstack_project.buildingblocks-testing.metadata.owned_by_workspace
    platform_identifier = "gcp.gcp-meshstack-dev"
  }
  spec = {
    landing_zone_identifier = "likvid-gcp-dev"
  }
}
