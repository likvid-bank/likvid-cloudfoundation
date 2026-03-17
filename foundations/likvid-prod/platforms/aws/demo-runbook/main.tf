resource "local_file" "part1_organization" {
  filename = "${var.output_dir}/part1-organization.md"
  content = templatefile("${path.module}/templates/part1-organization.md.tftpl", {
    org_id                                 = var.org_id
    org_root_id                            = var.org_root_id
    parent_ou_id                           = var.parent_ou_id
    payer_account_id                       = var.payer_account_id
    management_account_id                  = var.management_account_id
    networking_account_id                  = var.networking_account_id
    automation_account_id                  = var.automation_account_id
    meshstack_account_id                   = var.meshstack_account_id
    landingzones_ou_id                     = var.landingzones_ou_id
    cloud_native_ou_id                     = var.cloud_native_ou_id
    cloud_native_dev_ou_id                 = var.cloud_native_dev_ou_id
    cloud_native_prod_ou_id                = var.cloud_native_prod_ou_id
    on_prem_dev_ou_id                      = var.on_prem_dev_ou_id
    on_prem_prod_ou_id                     = var.on_prem_prod_ou_id
    bedrock_ou_id                          = var.bedrock_ou_id
    m25_platform_ou_id                     = var.m25_platform_ou_id
    deny_cloudtrail_deactivation_policy_id = var.deny_cloudtrail_deactivation_policy_id
  })
}

resource "local_file" "part2_audit_logs" {
  filename = "${var.output_dir}/part2-audit-logs.md"
  content = templatefile("${path.module}/templates/part2-audit-logs.md.tftpl", {
    payer_account_id      = var.payer_account_id
    management_account_id = var.management_account_id
    org_trail_arn         = var.org_trail_arn
    trail_s3_bucket       = var.trail_s3_bucket
  })
}

resource "local_file" "part3_bedrock" {
  filename = "${var.output_dir}/part3-bedrock.md"
  content = templatefile("${path.module}/templates/part3-bedrock.md.tftpl", {
    landingzones_ou_id = var.landingzones_ou_id
    bedrock_ou_id      = var.bedrock_ou_id
  })
}
