resource "aws_cloudformation_stack_set" "building_block_service_permissions" {
  name = "${var.building_block_target_account_access_role_name}Permissons"

  template_body = jsonencode({
    AWSTemplateFormatVersion = "2010-09-09",
    Description              = "Create an administrative IAM role in member accounts",
    Resources = {
      BuildingBlockServiceRole = {
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

  capabilities = ["CAPABILITY_IAM"]
}
