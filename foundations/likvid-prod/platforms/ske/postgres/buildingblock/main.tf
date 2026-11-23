locals {
  name        = replace("${var.workspace_identifier}_${var.project_identifier}", "-", "_")
  secret_name = "postgres"

  # Unique per order, because the Jobs of all orders share var.job_namespace.
  job_name = "postgres-revoke-${trim(substr(replace(lower(local.name), "_", "-"), 0, 38), "-")}-${substr(sha256(local.name), 0, 6)}"
}

module "database" {
  source = "github.com/meshcloud/meshstack-hub//modules/stackit/postgres/buildingblock/modules/database?ref=865da316ac07c76c5a65b633a07cc53097a8cdc9"

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

resource "kubernetes_secret_v1" "job_password" {
  metadata {
    name      = local.job_name
    namespace = var.job_namespace
  }

  data = {
    PGPASSWORD = module.database.password
  }
}

# PostgreSQL lets every user of the instance connect to every database. Only the owner can end
# that, and only clients in the instance ACL reach it, so the statement runs in the cluster.
# The app's namespace quota is often used up by the app itself, so the Job runs in the platform's.
resource "kubernetes_job_v1" "revoke_public" {
  metadata {
    name      = local.job_name
    namespace = var.job_namespace
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
                name = kubernetes_secret_v1.job_password.metadata[0].name
                key  = "PGPASSWORD"
              }
            }
          }

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
