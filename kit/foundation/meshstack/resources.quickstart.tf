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

# The platform refs come from the shared data sources in data.platforms.tf.

resource "meshstack_tenant" "quickstart_aws" {
  metadata = {
    owned_by_project   = meshstack_project.quickstart.metadata.name
    owned_by_workspace = "m25-platform"
  }
  spec = {
    platform_ref     = one(data.meshstack_platforms.aws.platforms).ref
    landing_zone_ref = { name = "likvid-aws-dev" }
  }

  # Destroying or replacing this tenant runs its building block's teardown, which deletes the live AWS
  # account. `platform_ref` is RequiresReplace, so a plan can ask for that replacement without anyone
  # intending it — this turns such a plan into an error.
  lifecycle {
    prevent_destroy = true
  }
}

resource "meshstack_tenant" "quickstart_azure" {
  metadata = {
    owned_by_workspace = "m25-platform"
    owned_by_project   = meshstack_project.quickstart.metadata.name
  }

  spec = {
    platform_ref     = one(data.meshstack_platforms.azure.platforms).ref
    landing_zone_ref = { name = "likvid-azure-dev" }
  }

  # Destroying or replacing this tenant runs its building block's teardown, which deletes the live
  # Azure subscription. `platform_ref` is RequiresReplace, so a plan can ask for that replacement
  # without anyone intending it — this turns such a plan into an error.
  lifecycle {
    prevent_destroy = true
  }
}

resource "meshstack_tenant" "quickstart_gcp" {
  metadata = {
    owned_by_workspace = "m25-platform"
    owned_by_project   = meshstack_project.quickstart.metadata.name
  }

  spec = {
    platform_ref     = one(data.meshstack_platforms.gcp.platforms).ref
    landing_zone_ref = { name = "likvid-gcp-dev" }
  }

  # Destroying or replacing this tenant runs its building block's teardown, which deletes the live GCP
  # project. `platform_ref` is RequiresReplace, so a plan can ask for that replacement without anyone
  # intending it — this turns such a plan into an error.
  lifecycle {
    prevent_destroy = true
  }
}
