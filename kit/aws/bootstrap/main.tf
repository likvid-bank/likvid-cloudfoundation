
data "aws_ssoadmin_instances" "sso" {}

locals {
  identity_store_arn = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
  identity_store_id  = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]
}

resource "aws_ssoadmin_permission_set" "platform_engineers" {
  instance_arn     = local.identity_store_arn
  name             = substr(var.platform_engineers_group.name, 0, 32) # ugly, but effective to stay within aws limit
  description      = "A permission set for the ${var.platform_engineers_group.name} group"
  session_duration = "PT1H" # 1 hour session duration

  relay_state = "https://aws.amazon.com"
}

resource "aws_ssoadmin_permission_set_inline_policy" "platform_engineers" {
  inline_policy      = file(".//cfn-tf-deploy.policy.json")
  instance_arn       = local.identity_store_arn
  permission_set_arn = aws_ssoadmin_permission_set.platform_engineers.arn
}

resource "aws_ssoadmin_account_assignment" "platform_engineers" {
  instance_arn       = aws_ssoadmin_permission_set.platform_engineers.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.platform_engineers.arn
  principal_type     = "GROUP"
  principal_id       = aws_identitystore_group.platform_engineers.group_id
  target_id          = var.aws_root_account_id
  target_type        = "AWS_ACCOUNT"
}