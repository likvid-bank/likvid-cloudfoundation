# Hub building-block coordinates — single source of truth for both the deployment
# (terragrunt.hcl) and the e2e smoke test (e2e/terragrunt.hcl), so the two cannot drift.
locals {
  module = "gcp/budget-alert"

  # Head of meshstack-hub PR #340. Re-pin to the merge commit once that PR lands.
  git_ref = "a881025eb5f7b41af12fbc0841ab93fda2470160"

  # Draft, so a version can be superseded without publishing a release to the catalog.
  bbd_draft = true
}
