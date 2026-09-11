# This unit supersedes the `backplane/` and `test/` units that stood here, which pinned two
# different hub refs. The backplane is now a child of the module that also owns the building block
# definition, so one apply can swap the backplane's credential and rewrite the definition that
# carries it — the pre-WIF IAM access key stops working the moment it is destroyed.
#
# Two manual steps precede the first plan; both are spelled out in the PR description:
#   1. Copy the old unit's state to this unit's key (terragrunt derives it from the path).
#   2. `terragrunt import 'module.budget_alert.meshstack_building_block_definition.this' <uuid>` —
#      the definition was made by hand in the demo panel. Without the import the apply publishes a
#      second catalog entry, and the e2e sibling then fails at plan time because it looks the
#      definition up by display name and `one()` rejects a duplicate.
#
# The blocks below then re-address the StackSet into the child module. Without them the StackSet is
# destroyed and recreated, which strips the target role from every account in the landing zones OU
# and breaks the running building blocks along with it.

moved {
  from = aws_cloudformation_stack_set.permissions_in_target_accounts
  to   = module.budget_alert.module.backplane.aws_cloudformation_stack_set.permissions_in_target_accounts
}

moved {
  from = aws_cloudformation_stack_set_instance.permissions_in_target_accounts
  to   = module.budget_alert.module.backplane.aws_cloudformation_stack_set_instance.permissions_in_target_accounts
}

# `aws_iam_user.backplane`, `aws_iam_access_key.backplane` and `aws_iam_user_policy.assume_roles`
# get no destination: workload identity federation replaces them, so they are meant to be
# destroyed. Their state entries still name the `aws.backplane` provider alias, which is why
# terragrunt.hcl keeps generating it until this migration has been applied.
