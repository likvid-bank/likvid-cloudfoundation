resource "meshstack_project" "quickstart" {
  provider = meshstack.quickstart
  metadata = {
    name               = "quickstart-infra-prod"
    owned_by_workspace = "m25-platform"
  }
  spec = {
    display_name              = "Quickstart Infrastructure"
    payment_method_identifier = "m25-platform"
    tags = {
      "environment"          = ["prod"]
      "Schutzbedarf"         = ["public"]
      "LandingZoneClearance" = ["cloud-native"]
      "projectOwner"         = ["Anna Admin"]
    }
  }
}

resource "meshstack_tenant" "quickstart_aws" {
  provider = meshstack.quickstart
  metadata = {
    owned_by_project    = meshstack_project.quickstart.metadata.name
    owned_by_workspace  = "m25-platform"
    platform_identifier = "aws.aws-meshstack-dev"
  }
  spec = {
    landing_zone_identifier = "likvid-aws-prod"
  }
}
