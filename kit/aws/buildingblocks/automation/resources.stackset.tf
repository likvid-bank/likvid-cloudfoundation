resource "aws_cloudformation_stack_set" "permissions_in_target_accounts" {
  name             = "${var.foundation}-${var.building_block_target_account_access_role_name}Permissons"
  permission_model = "SERVICE_MANAGED"
  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }
  operation_preferences {
    failure_tolerance_count = 50
    max_concurrent_count    = 50
  }

  template_body = jsonencode({
    AWSTemplateFormatVersion = "2010-09-09",
    Description              = "Create an administrative IAM role in member accounts",
    Resources = {
      BuildingBlockServiceRolePermissions = {
        Type = "AWS::IAM::Role",
        Properties = {
          RoleName = var.building_block_target_account_access_role_name,
          AssumeRolePolicyDocument = {
            Version = "2012-10-17",
            Statement = [
              {
                Effect = "Allow",
                Principal = {
                  AWS = "arn:${data.aws_partition.current.partition}:iam::${var.building_block_backend_account_id}:user/${aws_iam_user.user.name}"
                },
                Action = "sts:AssumeRole"
              }
            ]
          },
          Policies = [
            {
              PolicyName = "FullAccessPolicy",
              PolicyDocument = {
                Version = "2012-10-17",
                Statement = [
                  {
                    Effect   = "Allow",
                    Action   = "*",
                    Resource = "*"
                  }
                ]
              }
            }
          ]
        }
      }
    }
  })

  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
}

data "aws_organizations_organization" "main" {}

resource "aws_cloudformation_stack_set_instance" "permissions_in_target_accounts" {
  deployment_targets {
    organizational_unit_ids = var.building_block_target_ou_ids
  }

  region         = "eu-central-1"
  stack_set_name = aws_cloudformation_stack_set.permissions_in_target_accounts.name
}
