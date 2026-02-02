module "meshplatform" {
  source  = "meshcloud/meshplatform/aws"
  version = "0.5.1"

  providers = {
    aws.management = aws.management
    aws.meshcloud  = aws.meshcloud
    aws.automation = aws.automation
  }

  aws_sso_instance_arn                 = var.aws_sso_instance_arn
  replicator_privileged_external_id    = var.replicator_privileged_external_id
  cost_explorer_privileged_external_id = var.cost_explorer_privileged_external_id
  support_root_account_via_aws_sso     = var.support_root_account_via_aws_sso

  management_account_service_role_name = var.management_account_service_role_name
  meshcloud_account_service_user_name  = var.meshcloud_account_service_user_name
  automation_account_service_role_name = var.automation_account_service_role_name

  cost_explorer_management_account_service_role_name = var.cost_explorer_management_account_service_role_name
  cost_explorer_meshcloud_account_service_user_name  = var.cost_explorer_meshcloud_account_service_user_name

  control_tower_enrollment_enabled = var.control_tower_enrollment_enabled
  control_tower_portfolio_id       = var.control_tower_portfolio_id
  landing_zone_ou_arns             = var.landing_zone_ou_arns

  can_close_accounts_with_tags = var.can_close_accounts_with_tags

  create_access_keys           = var.create_access_keys
  workload_identity_federation = var.workload_identity_federation
}
