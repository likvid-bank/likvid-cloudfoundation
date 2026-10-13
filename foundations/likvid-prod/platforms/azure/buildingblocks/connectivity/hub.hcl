# Hub building-block coordinates — single source of truth for both the deployment
# (terragrunt.hcl) and the e2e smoke test (e2e/terragrunt.hcl).
locals {
  module = "azure/spoke-network"

  # A commit on main: a PR head stops resolving once its branch is squash-merged and deleted.
  git_ref = "312039026a5051435322a10d53ede50dc2214735"

  # Released: the smoke test orders from devops-platform, and a draft is visible to its owner alone.
  #
  # A released version is immutable, so any change to the definition, a new git_ref included, takes
  # two applies: one with `true` to create the next version as a draft, then one with `false` to
  # release it. Applying a change with `false` alone fails with "released versions are immutable".
  bbd_draft = false
}
