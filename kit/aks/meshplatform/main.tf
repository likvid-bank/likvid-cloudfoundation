# Place your module's terraform resources here as usual.
# Note that you should typically not put a terraform{} block into cloud foundation kit modules,
# these will be provided by the platform implementations using this kit module.
module "meshplatform" {
  source = "git::https://github.com/meshcloud/terraform-aks-meshplatform.git?ref=88fc6ed79457cd7c52c730df50abba451df5e2ac"

  metering_enabled             = var.metering_enabled
  metering_additional_rules    = var.metering_additional_rules
  replicator_enabled           = var.replicator_enabled
  replicator_additional_rules  = var.replicator_additional_rules
  scope                        = var.scope
  service_principal_name       = var.service_principal_name
  create_password              = var.create_password
  workload_identity_federation = var.workload_identity_federation
}
