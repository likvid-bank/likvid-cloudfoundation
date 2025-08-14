module "meshplatform" {
  source  = "meshcloud/meshplatform/azure"
  version = "v0.13.3"

  ## use for testing locally
  # source = "./terraform-azure-meshplatform"

  metering_enabled                      = var.metering_enabled
  metering_service_principal_name       = var.metering_service_principal_name
  metering_assignment_scopes            = var.metering_assignment_scopes
  sso_enabled                           = var.sso_enabled
  replicator_enabled                    = var.replicator_enabled
  replicator_rg_enabled                 = var.replicator_rg_enabled
  replicator_service_principal_name     = var.replicator_service_principal_name
  replicator_custom_role_scope          = var.replicator_custom_role_scope
  replicator_assignment_scopes          = var.replicator_assignment_scopes
  additional_permissions                = var.additional_permissions
  additional_required_resource_accesses = var.additional_required_resource_accesses
  create_passwords                      = var.create_passwords
  workload_identity_federation          = var.workload_identity_federation
  can_cancel_subscriptions_in_scopes    = var.can_cancel_subscriptions_in_scopes
  can_delete_rgs_in_scopes              = var.can_delete_rgs_in_scopes
  administrative_unit_name              = var.administrative_unit_name

  mca = var.mca
}
