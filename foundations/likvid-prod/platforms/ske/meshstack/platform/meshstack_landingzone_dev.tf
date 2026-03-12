output "landing_zone_dev_identifier" {
  description = "The meshstack landing zone identifier for SKE dev namespaces"
  value       = meshstack_landingzone.dev.metadata.name
}

resource "meshstack_landingzone" "dev" {
  metadata = {
    name               = "ske-namespace-dev"
    owned_by_workspace = var.owning_workspace_identifier
    tags = {
      "LandingZoneFamily" = ["cloud-native"]
      "environment"       = ["dev"]
      "confidentiality"   = ["internal", "public"]
    }
  }

  spec = {
    display_name                  = "SKE Kubernetes Namespace – Development"
    description                   = "Landing zone for development."
    automate_deletion_approval    = true
    automate_deletion_replication = true
    info_link                     = "https://likvid-bank.github.io/likvid-cloudfoundation/platforms/stackit/landingzones/dev.html"

    platform_ref = {
      uuid = meshstack_platform.ske.metadata.uuid
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

    quotas = [
      { key = "limits.cpu", value = 500 },
      { key = "requests.cpu", value = 250 },
      { key = "limits.memory", value = 512 },
      { key = "requests.memory", value = 256 },
      { key = "requests.storage", value = 1 },
      { key = "persistentvolumeclaims", value = 2 },
    ]
  }
}
