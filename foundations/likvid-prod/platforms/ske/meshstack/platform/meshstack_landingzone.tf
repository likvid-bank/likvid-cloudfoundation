output "landing_zone_identifiers" {
  description = "meshstack landing zone identifiers keyed by environment."
  value = {
    for env, lz in meshstack_landingzone.this : env => lz.metadata.name
  }
}

locals {
  landing_zones = {
    dev = {
      display_name = "SKE Kubernetes Namespace – Development"
      description  = "Landing zone for development workloads."
      quotas = [
        { key = "limits.cpu", value = 500 },
        { key = "requests.cpu", value = 250 },
        { key = "limits.memory", value = 512 },
        { key = "requests.memory", value = 256 },
        { key = "requests.storage", value = 1 },
        { key = "persistentvolumeclaims", value = 2 },
      ]
    }
    prod = {
      display_name = "SKE Kubernetes Namespace – Production"
      description  = "Landing zone for production workloads."
      quotas = [
        { key = "limits.cpu", value = 1000 },
        { key = "requests.cpu", value = 500 },
        { key = "limits.memory", value = 1024 },
        { key = "requests.memory", value = 512 },
        { key = "requests.storage", value = 2 },
        { key = "persistentvolumeclaims", value = 4 },
      ]
    }
  }
}

resource "meshstack_landingzone" "this" {
  for_each = local.landing_zones

  metadata = {
    name               = "ske-namespace-${each.key}"
    owned_by_workspace = var.meshstack.owning_workspace_identifier
    tags = {
      "LandingZoneFamily" = ["cloud-native"]
      "environment"       = [each.key]
      "confidentiality"   = each.key == "prod" ? ["public"] : ["internal"]
    }
  }

  spec = {
    display_name                  = each.value.display_name
    description                   = each.value.description
    automate_deletion_approval    = true
    automate_deletion_replication = true
    info_link                     = "https://likvid-bank.github.io/likvid-cloudfoundation/platforms/stackit/landingzones/${each.key}.html"

    platform_ref = {
      uuid = meshstack_platform.this.metadata.uuid
    }

    platform_properties = {
      kubernetes = {
        kubernetes_role_mappings = [
          {
            project_role_ref = { name = "admin" }
            platform_roles   = ["admin"]
          },
          {
            project_role_ref = { name = "user" }
            platform_roles   = ["edit"]
          },
          {
            project_role_ref = { name = "reader" }
            platform_roles   = ["view"]
          },
        ]
      }
    }

    quotas = each.value.quotas
  }
}

moved {
  from = meshstack_landingzone.dev
  to   = meshstack_landingzone.this["dev"]
}

moved {
  from = meshstack_landingzone.prod
  to   = meshstack_landingzone.this["prod"]
}


