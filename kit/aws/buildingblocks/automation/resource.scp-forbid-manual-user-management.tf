resource "aws_organizations_policy" "deny_create_iam_user" {
  name        = "${var.foundation}-DenyCreateIAMUser"
  description = "Deny the creation of IAM users except for a specific role"
  content     = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyCreateIAMUsers",
      "Effect": "Deny",
      "Action": [
        "iam:CreateUser",
        "iam:UpdateUser",
        "iam:DeleteUser"
      ],
      "Resource": "*",
      "Condition": {
        "StringNotLike": {
          "aws:PrincipalArn": "arn:aws:iam::*:role/${var.building_block_target_account_access_role_name}"
        }
      }
    }
  ]
}
POLICY
  type        = "SERVICE_CONTROL_POLICY"
}

resource "aws_organizations_policy_attachment" "deny_create_iam_user" {
  for_each  = var.building_block_target_ou_ids
  policy_id = aws_organizations_policy.deny_create_iam_user.id
  target_id = each.key
}
