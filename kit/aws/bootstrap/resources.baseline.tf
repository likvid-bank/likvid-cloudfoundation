# TODO: a better way to model all of this so that it better aligns with our Azure and GCP architecture is to treat
# the "root" like the ORG level and the management account as the "foundation/management project"

# "baseline" is a global stackset applied to every account in the entire ORG
resource "aws_cloudformation_stack_set" "baseline" {
  name = "${var.foundation}-foundation-baseline"

  template_body = jsonencode({
    Resources = {
      FoundationAuditorRole = {
        Type = "AWS::IAM::Role"
        Properties = {
          RoleName = var.validation_role_name
          AssumeRolePolicyDocument = {
            Version = "2012-10-17"
            Statement = [
              {
                Effect = "Allow"
                Principal = {
                  # Trust any principal on the root account to assume this role.
                  # Of course that principal must have permission to call sts:assumeRole on the root account too
                  AWS = "arn:aws:iam::${var.management_account_id}:root"
                }
                Action = [
                  "sts:AssumeRole"
                ]
              },
            ]
          }
          ManagedPolicyArns = [
            "arn:aws:iam::aws:policy/ReadOnlyAccess",
          ]
        }
      }
    }
  })

  capabilities = ["CAPABILITY_NAMED_IAM"]

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  permission_model = "SERVICE_MANAGED"

  lifecycle {
    ignore_changes = [
      administration_role_arn // ignored becuase we use a SERVICE_MANAGED stackset
    ]
  }
}

# Deploy the StackSet to all child accounts hosted in the organization
# New accounts should be automatically enrolled thanks to auto_deployment, but we had to bring in some legacy ones as well
resource "aws_cloudformation_stack_set_instance" "baseline" {
  stack_set_name = aws_cloudformation_stack_set.baseline.name
  deployment_targets {
    organizational_unit_ids = [var.parent_ou_id]
  }
}

# TODO: This is a temporary hack until we have moved out stuff from the root account into the automation account
# we cannot include the root account in the stackset, so we simply deploy the same template to it as its own stack
resource "aws_cloudformation_stack" "root_baseline" {
  name          = aws_cloudformation_stack_set.baseline.name
  template_body = aws_cloudformation_stack_set.baseline.template_body
  capabilities  = aws_cloudformation_stack_set.baseline.capabilities

}

output "baseline_cloudformation_template" {
  value = tostring(aws_cloudformation_stack_set.baseline.template_body)
}
