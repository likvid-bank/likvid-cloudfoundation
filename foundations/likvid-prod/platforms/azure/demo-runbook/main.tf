locals {
  # Extract management group names from their full resource IDs
  # Format: /providers/Microsoft.Management/managementGroups/<name>
  parent_mg_name       = element(split("/", var.parent_mg_id), length(split("/", var.parent_mg_id)) - 1)
  landingzones_mg_name = element(split("/", var.landingzones_mg_id), length(split("/", var.landingzones_mg_id)) - 1)
  platform_mg_name     = element(split("/", var.platform_mg_id), length(split("/", var.platform_mg_id)) - 1)
  connectivity_mg_name = element(split("/", var.connectivity_mg_id), length(split("/", var.connectivity_mg_id)) - 1)
  identity_mg_name     = element(split("/", var.identity_mg_id), length(split("/", var.identity_mg_id)) - 1)
  management_mg_name   = element(split("/", var.management_mg_id), length(split("/", var.management_mg_id)) - 1)
  sandbox_mg_name      = element(split("/", var.sandbox_mg_id), length(split("/", var.sandbox_mg_id)) - 1)
}

resource "local_file" "part1_management_groups" {
  filename = "${var.output_dir}/part1-management-groups.md"
  content = templatefile("${path.module}/templates/part1-management-groups.md.tftpl", {
    tenant_id            = var.tenant_id
    parent_mg_id         = var.parent_mg_id
    parent_mg_name       = local.parent_mg_name
    landingzones_mg_id   = var.landingzones_mg_id
    landingzones_mg_name = local.landingzones_mg_name
    platform_mg_id       = var.platform_mg_id
    platform_mg_name     = local.platform_mg_name
    connectivity_mg_id   = var.connectivity_mg_id
    connectivity_mg_name = local.connectivity_mg_name
    identity_mg_id       = var.identity_mg_id
    identity_mg_name     = local.identity_mg_name
    management_mg_id     = var.management_mg_id
    management_mg_name   = local.management_mg_name
  })
}

resource "local_file" "part2_logging" {
  filename = "${var.output_dir}/part2-logging.md"
  content = templatefile("${path.module}/templates/part2-logging.md.tftpl", {
    tenant_id               = var.tenant_id
    parent_mg_id            = var.parent_mg_id
    parent_mg_name          = local.parent_mg_name
    law_workspace_id        = var.law_workspace_id
    logging_subscription_id = var.logging_subscription_id
    log_retention_days      = var.log_retention_days
    management_mg_name      = local.management_mg_name
  })
}

resource "local_file" "part3_sandbox" {
  filename = "${var.output_dir}/part3-sandbox.md"
  content = templatefile("${path.module}/templates/part3-sandbox.md.tftpl", {
    tenant_id            = var.tenant_id
    sandbox_mg_id        = var.sandbox_mg_id
    sandbox_mg_name      = local.sandbox_mg_name
    landingzones_mg_id   = var.landingzones_mg_id
    landingzones_mg_name = local.landingzones_mg_name
  })
}
