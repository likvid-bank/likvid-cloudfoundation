output "stackit_project_id" {
  description = "STACKIT project UUID provisioned by meshStack replication – consumed by kubernetes/"
  value       = meshstack_tenant.this.spec.platform_tenant_id
}

# `meshstack_tenant.spec.platform_ref` needs a platform UUID, which only meshStack can supply, so the
# identifier is resolved into one here. A hardcoded UUID would tie this unit to one meshStack
# installation. The data source's `ref` is shaped for exactly this and passes straight through.
#
# The filter matches the full `<platform>.<location>` identifier, even though the provider documents
# it as matching `metadata.name` — filtering by the bare `likvid-stackit` returns nothing. `one()` makes
# the unit fail loudly if the filter ever stops matching exactly one platform.
data "meshstack_platforms" "stackit" {
  identifier = "likvid-stackit.global"
}

moved {
  from = meshstack_tenant_v4.stackit
  to   = meshstack_tenant_v4.this
}

moved {
  from = meshstack_tenant_v4.this
  to   = meshstack_tenant.this
}

# Moving this tenant from `stackit.sovereign` to `likvid-stackit.global` is deliberately not a Terraform
# change: `platform_ref` is RequiresReplace, and replacing a meshTenant destroys its building block and
# with it the live STACKIT project that runs the SKE cluster. The tenant was migrated out of band by
# `migration/migrate.sh`, then removed from state and re-imported at this address. The STACKIT project id
# is unchanged by the move, so `stackit_project_id` keeps resolving for `kubernetes/`, `dns/`, `git/` and
# `starterkit/`. See the stackit-starterkit plan.
resource "meshstack_tenant" "this" {
  metadata = {
    owned_by_workspace = local.owning_workspace_identifier
    owned_by_project   = meshstack_project.this.metadata.name
  }

  spec = {
    platform_ref     = one(data.meshstack_platforms.stackit.platforms).ref
    landing_zone_ref = { name = "likvid-stackit-default" }
  }

  # Destroying or replacing this tenant destroys its building block, and that block's teardown deletes
  # the STACKIT project the SKE cluster runs in. `platform_ref` is RequiresReplace, so a plan can ask
  # for that replacement without anyone intending it — this turns such a plan into an error. Four
  # downstream units read `stackit_project_id` from here.
  lifecycle {
    prevent_destroy = true
  }
}
