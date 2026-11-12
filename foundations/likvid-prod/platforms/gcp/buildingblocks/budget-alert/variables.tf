variable "hub" {
  type = object({
    git_ref   = string
    bbd_draft = bool
  })
  description = "Hub building-block coordinates. Single source of truth in hub.hcl, passed in by terragrunt."
}

variable "backplane_project_id" {
  type        = string
  description = "GCP project hosting the backplane service account and the Cloud Monitoring notification channels the alerts are delivered through."
}

variable "billing_account_id" {
  type        = string
  description = "GCP billing account the budgets are created under. Budgets are billing-account scoped, so this is also where the backplane is granted its budget roles."
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
  description = "The long-lived GCP tenant the foundation e2e smoke test orders its ephemeral building block against. Named by its workspace and GCP project id — readable identifiers — rather than by a meshTenant uuid, which is resolved from them below."
}
