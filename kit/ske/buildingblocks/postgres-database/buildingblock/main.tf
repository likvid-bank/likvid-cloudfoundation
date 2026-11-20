locals {
  name        = replace("${var.workspace_identifier}_${var.project_identifier}", "-", "_")
  secret_name = "postgres"
}

module "database" {
  source = "github.com/meshcloud/meshstack-hub//modules/stackit/postgres/buildingblock/modules/database?ref=e9351060d9a87b1a7e4ea5f8f2bd47016e1d691c"

  project_id    = var.stackit_project_id
  instance_id   = var.instance_ids[var.landing_zone_identifier]
  database_name = local.name
  username      = local.name
}

resource "kubernetes_secret_v1" "datasource" {
  metadata {
    name      = local.secret_name
    namespace = var.namespace
  }

  data = {
    SPRING_DATASOURCE_URL      = module.database.jdbc_url
    SPRING_DATASOURCE_USERNAME = module.database.username
    SPRING_DATASOURCE_PASSWORD = module.database.password
  }
}

# PostgreSQL lets every user of the instance connect to every database. Only the owner can end
# that, and only clients in the instance ACL reach it, so the statement runs in the cluster.
resource "kubernetes_job_v1" "revoke_public" {
  metadata {
    name      = "postgres-revoke-public"
    namespace = var.namespace
  }

  wait_for_completion = true

  timeouts {
    create = "5m"
  }

  spec {
    backoff_limit = 3

    template {
      metadata {}

      spec {
        restart_policy                  = "Never"
        automount_service_account_token = false

        security_context {
          run_as_non_root = true
          run_as_user     = 70
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        container {
          name    = "psql"
          image   = "postgres:17.12-alpine"
          command = ["psql", "-v", "ON_ERROR_STOP=1", "-c", "REVOKE ALL ON DATABASE \"${module.database.database}\" FROM PUBLIC"]

          env {
            name  = "PGHOST"
            value = module.database.host
          }
          env {
            name  = "PGPORT"
            value = tostring(module.database.port)
          }
          env {
            name  = "PGDATABASE"
            value = module.database.database
          }
          env {
            name  = "PGUSER"
            value = module.database.username
          }
          env {
            name  = "PGSSLMODE"
            value = "require"
          }
          env {
            name = "PGPASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.datasource.metadata[0].name
                key  = "SPRING_DATASOURCE_PASSWORD"
              }
            }
          }

          # The namespace quota `mesh-quotas` must also fit the app's two pods of a rolling update.
          resources {
            requests = { cpu = "10m", memory = "32Mi" }
            limits   = { cpu = "50m", memory = "64Mi" }
          }

          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = ["ALL"]
            }
          }
        }
      }
    }
  }
}
