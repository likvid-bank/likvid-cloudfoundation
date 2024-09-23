
output "documentation_md" {
  value = <<EOF
# Deployment Automation

This platform is bootstrapped in the AWS Root Account with number `${var.management_account_id}`.

## Platform Engineer Access Management

The `${aws_identitystore_group.platform_engineers.display_name}` group is used to grant privileged access to members of the
cloud foundation team. The group has the following members:

${join("\n", formatlist("- %s", var.platform_engineers_group.members))}

## Automation

We allow GitHub actions from the `${var.github_repo_full_name}` repository to access the `${aws_iam_role.validation.name}` role.
This role grants read-only access to our AWS Organization and allows the cloud foundation team to automate validation of the deployment.

EOF
}
