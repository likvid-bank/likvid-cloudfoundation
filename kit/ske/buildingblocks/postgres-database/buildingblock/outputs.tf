output "database" {
  value       = module.database.database
  description = "Name of the database."
}

output "username" {
  value       = module.database.username
  description = "Name of the database user that owns the database."
}

output "host" {
  value       = module.database.host
  description = "DNS name of the shared instance's write endpoint."
}

output "port" {
  value       = module.database.port
  description = "TCP port of the shared instance's write endpoint."
}

output "secret_name" {
  value       = kubernetes_secret_v1.datasource.metadata[0].name
  description = "Name of the Kubernetes Secret with the connection settings."
}

output "summary" {
  description = "Markdown summary shown in meshPanel after the run."
  value       = <<-EOT
    # PostgreSQL database `${module.database.database}`

    Your namespace `${var.namespace}` has a database of its own on the shared PostgreSQL instance
    `${module.database.instance_name}` of the landing zone `${var.landing_zone_identifier}`.

    | | |
    |---|---|
    | **Database** | `${module.database.database}` |
    | **User** (owner) | `${module.database.username}` |
    | **Host** | `${module.database.host}` |
    | **Port** | `${module.database.port}` |
    | **Kubernetes Secret** | `${kubernetes_secret_v1.datasource.metadata[0].name}` in `${var.namespace}` |

    The Secret holds `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME` and
    `SPRING_DATASOURCE_PASSWORD`. A pod reads all three with `envFrom`. The password is stored
    nowhere else.

    ## Next step: redeploy

    Running pods do not see a new Secret. Run your pipeline again for this stage, with a push or
    a manual run of the workflow on the stage's branch. The next deployment connects to PostgreSQL.

    ## Good to know

    - The connection requires TLS (`sslmode=require`) and works from this cluster only.
    - No other user of the shared instance can connect to your database.
    - Schema, migrations and data are yours. Deleting this building block deletes the database.
  EOT
}
