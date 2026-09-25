# Hub building-block coordinates — single source of truth for both the deployment
# (terragrunt.hcl) and the e2e smoke test (e2e/terragrunt.hcl), so the two cannot drift.
#
# It also ends the divergence this unit carried: the backplane was pinned to 5868eeeb while the
# test next to it ran the building block from e71a223f.
locals {
  module = "aws/budget-alert"

  # Head of meshstack-hub PR #341. Re-pin to the merge commit once that PR lands.
  git_ref = "c6d2a3506c4f49fa7b53857a1512fd02397346fc"

  # Released, not draft: this is the demo catalog, and the version that replaces the hand-made
  # definition has to be orderable — the migration invalidates the credential the current one
  # carries.
  bbd_draft = false
}
