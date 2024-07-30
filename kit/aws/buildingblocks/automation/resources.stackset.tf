resource "aws_cloudformation_stack_set" "permissions_in_target_accounts" {
  name             = "${var.building_block_target_account_access_role_name}Permissons"
  permission_model = "SERVICE_MANAGED"
  auto_deployment { enabled = true }

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
                  AWS = "arn:aws:iam::${var.building_block_backend_account_id}:root"
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
    organizational_unit_ids = [data.aws_organizations_organization.main.roots[0].id] #TODO scope permissions on landing zone OUs
  }

  region         = "eu-central-1"
  stack_set_name = aws_cloudformation_stack_set.permissions_in_target_accounts.name
}
