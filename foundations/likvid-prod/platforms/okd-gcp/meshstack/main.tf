# The okd-gcp meshPlatform itself predates this repo and is still managed in the meshStack panel:
# its replication and metering tokens are not stored anywhere we can read them, so importing it
# would make Terraform overwrite them. The landing zones below are managed as code.
locals {
  owning_workspace_identifier = "likvid-cloud"

  platform_ref = {
    uuid = "a73f7b09-d2f4-11ed-8b54-0e0c9ab060b8" # okd-gcp, "OKD on Google Cloud"
    kind = "meshPlatform"
  }

  # Quota keys follow the platform's quota definitions: cpu in millicores, memory in Mi.
  landing_zones = {
    dev = {
      display_name = "OpenShift on GCP – Development"
      description  = "Landing zone for development workloads."
      quotas = [
        { key = "cpu", value = 1000 },
        { key = "memory", value = 2048 },
      ]
    }
    prod = {
      display_name = "OpenShift on GCP – Production"
      description  = "Landing zone for production workloads."
      quotas = [
        { key = "cpu", value = 2000 },
        { key = "memory", value = 4096 },
      ]
    }
  }
}

resource "meshstack_landingzone" "this" {
  for_each = local.landing_zones

  metadata = {
    name               = "okd-gcp-${each.key}"
    owned_by_workspace = local.owning_workspace_identifier
    tags = {
      "LandingZoneFamily" = ["container-platform"]
      "environment"       = [each.key]
      "confidentiality"   = each.key == "prod" ? ["public"] : ["internal"]
    }
  }

  spec = {
    display_name                  = each.value.display_name
    description                   = each.value.description
    automate_deletion_approval    = true
    automate_deletion_replication = true
    info_link                     = ""

    platform_ref = {
      uuid = local.platform_ref.uuid
    }

    platform_properties = {
      openshift = {}
    }

    quotas = each.value.quotas
  }
}

output "owned_by_workspace" {
  description = "The meshStack workspace that owns the OpenShift on GCP platform resources."
  value       = local.owning_workspace_identifier
}

output "platform_ref" {
  description = "Reference to the okd-gcp meshPlatform."
  value       = local.platform_ref
}

output "landing_zone_refs" {
  description = "References to the meshLandingZones, keyed by stage."
  value = {
    for stage, lz in meshstack_landingzone.this : stage => lz.ref
  }
}
