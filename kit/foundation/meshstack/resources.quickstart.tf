resource "meshstack_project" "quickstart" {
  metadata = {
    name               = "quickstart-infra-likvid"
    owned_by_workspace = "m25-platform"
  }
  spec = {
    display_name              = "Quickstart Infrastructure"
    payment_method_identifier = "m25-platform"
    tags = {
      "environment"          = ["dev"]
      "Schutzbedarf"         = ["public"]
      "LandingZoneClearance" = ["cloud-native"]
      "projectOwner"         = ["Anna Admin"]
    }
  }
}

resource "meshstack_tenant" "quickstart_aws" {
  metadata = {
    owned_by_project    = meshstack_project.quickstart.metadata.name
    owned_by_workspace  = "m25-platform"
    platform_identifier = "aws.aws-meshstack-dev"
  }
  spec = {
    landing_zone_identifier = "likvid-aws-dev"
  }
}

resource "meshstack_tenant_v4" "quickstart_azure" {
  metadata = {
    owned_by_workspace = "m25-platform"
    owned_by_project   = meshstack_project.quickstart.metadata.name
  }

  spec = {
    platform_identifier     = "azure.meshcloud-azure-dev"
    landing_zone_identifier = "likvid-azure-dev"
  }
}

resource "meshstack_tenant_v4" "quickstart_gcp" {
  metadata = {
    owned_by_workspace = "m25-platform"
    owned_by_project   = meshstack_project.quickstart.metadata.name
  }

  spec = {
    platform_identifier     = "gcp.gcp-meshstack-dev"
    landing_zone_identifier = "likvid-gcp-dev"
  }
}
