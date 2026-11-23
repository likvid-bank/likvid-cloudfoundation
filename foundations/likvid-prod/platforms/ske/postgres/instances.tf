locals {
  instances = {
    dev  = { replicas = 1, flavor = "2.4", storage_size_in_gb = 5 }
    prod = { replicas = 3, flavor = "2.4", storage_size_in_gb = 5 }
  }
}

module "instance_definition" {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/stackit/postgres?ref=${var.hub.git_ref}"

  stackit_service_account_email = local.service_account_email
  stackit_acl                   = local.cluster_egress_address_ranges

  meshstack = {
    owning_workspace_identifier = local.owning_workspace_identifier
    runner_ref                  = local.runner_ref
  }
  # Only devops-platform orders it, and an owner can order a draft.
  hub = merge(var.hub, { bbd_draft = true })
}

# The module's output has no `ref`, which the platform's federation takes.
data "meshstack_building_block_definition" "instance" {
  metadata = { uuid = module.instance_definition.building_block_definition.uuid }
}

resource "meshstack_building_block" "instance" {
  for_each = var.order_instances ? local.instances : {}

  # Their runs act as the service account, which needs the role first.
  depends_on = [stackit_authorization_project_role_assignment.platform]

  wait_for_completion = true

  lifecycle {
    postcondition {
      condition     = self.status.succeeded
      error_message = "Building block ${self.metadata.uuid} did not succeed: health status ${self.status.health_status}, action ${self.status.action}. See its run in meshPanel."
    }
  }

  spec = {
    building_block_definition_version_ref = module.instance_definition.building_block_definition.version_ref
    display_name                          = "Shared PostgreSQL ${each.key}"
    target_ref                            = meshstack_tenant.stackit.ref

    inputs = {
      instance_name         = { value = jsonencode("shared-${each.key}") }
      flavor                = { value = jsonencode(each.value.flavor) }
      replicas              = { value = jsonencode(tostring(each.value.replicas)) }
      storage_class         = { value = jsonencode("premium-perf2-stackit") }
      storage_size          = { value = jsonencode(each.value.storage_size_in_gb) }
      postgres_version      = { value = jsonencode("17") }
      backup_schedule       = { value = jsonencode("0 2 * * *") }
      backup_retention_days = { value = jsonencode(32) }
      acl                   = { value = jsonencode(jsonencode(local.cluster_egress_address_ranges)) }
    }
  }
}
