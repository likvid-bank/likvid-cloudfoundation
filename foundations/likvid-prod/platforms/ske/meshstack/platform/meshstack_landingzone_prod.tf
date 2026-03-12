output "landing_zone_prod_identifier" {
  description = "The meshstack landing zone identifier for SKE prod namespaces"
  value       = meshstack_landingzone.prod.metadata.name
}

resource "meshstack_landingzone" "prod" {
  metadata = {
    name               = "ske-namespace-prod"
    owned_by_workspace = var.owning_workspace_identifier
    tags = {
      "LandingZoneFamily" = ["cloud-native"]
      "environment"       = ["prod"]
      "confidentiality"   = ["internal", "public"]
    }
  }

  spec = {
    display_name                  = "SKE Kubernetes Namespace – Production"
    description                   = "Landing zone for production workloads."
    automate_deletion_approval    = true
    automate_deletion_replication = true
    info_link                     = "https://likvid-bank.github.io/likvid-cloudfoundation/platforms/stackit/landingzones/prod.html"

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
      { key = "limits.cpu", value = 1000 },
      { key = "requests.cpu", value = 500 },
      { key = "limits.memory", value = 1024 },
      { key = "requests.memory", value = 512 },
      { key = "requests.storage", value = 2 },
      { key = "persistentvolumeclaims", value = 4 },
    ]
  }
}
