variable "hub" {
  type = object({
    git_ref   = string
    bbd_draft = bool
  })
  description = "Hub building-block coordinates. Single source of truth in hub.hcl, passed in by terragrunt."
}

variable "oidc_provider_arn" {
  type        = string
  description = "ARN of the meshStack runner's IAM OIDC provider in the automation account. Applied by the `oidc-provider` unit next door, because AWS allows only one provider per issuer per account."
}

variable "target_ou_ids" {
  type        = set(string)
  description = "AWS OUs whose accounts a budget can be created in. A budget belongs to the account whose spend it tracks, so the backplane distributes its target role to these OUs via a StackSet. An empty set would instead put the target role next to the backplane, which only fits a single-account deployment."
}

variable "target_account_role_name" {
  type        = string
  description = "Name of the IAM role the building block assumes in the account receiving the budget. Also the name of the StackSet that distributes it, so it must be unique within the AWS organization — and stable, or target accounts get a replaced role instead of an updated one."
}

variable "owning_workspace_identifier" {
  type        = string
  description = "meshWorkspace that owns the building block definition. The backplane's workload identity federation trusts exactly this workspace's building block runners, so it must match the workspace the definition lives in."
}

variable "smoke_test_tenant" {
  type = object({
    workspace          = string
    platform_tenant_id = string
  })
  description = "The long-lived AWS tenant the foundation e2e smoke test orders its ephemeral building block against. Named by its workspace and AWS account id — readable identifiers — rather than by a meshTenant uuid, which is resolved from them below."
}
