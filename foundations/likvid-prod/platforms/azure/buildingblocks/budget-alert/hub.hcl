# Hub building-block coordinates — single source of truth for both the deployment
# (terragrunt.hcl) and the e2e smoke test (e2e/terragrunt.hcl).
locals {
  module = "azure/budget-alert"

  # Head of meshstack-hub PR #339, which adds foundation mode to this module's e2e test.
  # RE-PIN to the merge commit once that PR lands.
  git_ref = "cb2af04c1332aa4e14bc21c94a8bd35bbd0770b3"

  # Draft, so the definition can be upgraded in place.
  bbd_draft = true
}
