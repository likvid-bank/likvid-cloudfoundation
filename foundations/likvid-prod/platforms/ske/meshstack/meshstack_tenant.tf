output "stackit_project_id" {
  description = "STACKIT project UUID provisioned by meshStack replication – consumed by kubernetes/"
  value       = meshstack_tenant.this.spec.platform_tenant_id
}

# `meshstack_tenant.spec.platform_ref` needs a platform UUID, which only meshStack can supply, so the
# identifier is resolved into one here. A hardcoded UUID would tie this unit to one meshStack
# installation. The data source's `ref` is shaped for exactly this and passes straight through.
#
# The filter matches the full `<platform>.<location>` identifier, even though the provider documents
# it as matching `metadata.name` — filtering by the bare `stackit` returns nothing. `one()` makes the
# unit fail loudly if the filter ever stops matching exactly one platform.
data "meshstack_platforms" "stackit" {
  identifier = "stackit.sovereign"
}

moved {
  from = meshstack_tenant_v4.stackit
  to   = meshstack_tenant_v4.this
}

moved {
  from = meshstack_tenant_v4.this
  to   = meshstack_tenant.this
}

resource "meshstack_tenant" "this" {
  metadata = {
    owned_by_workspace = local.owning_workspace_identifier
    owned_by_project   = meshstack_project.this.metadata.name
  }

  spec = {
    platform_ref     = one(data.meshstack_platforms.stackit.platforms).ref
    landing_zone_ref = { name = "stackit-prod" }
  }
}
