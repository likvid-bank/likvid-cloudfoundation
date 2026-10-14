# Hub building-block coordinates — single source of truth for the deployment (terragrunt.hcl) and a
# future e2e smoke test.
locals {
  module = "ansible/vm-hardening"

  # A commit on main: a PR head stops resolving once its branch is squash-merged and deleted.
  git_ref = "486b99e8b6469548dbaa9384436ab6b4a04c5239"

  # Released. A released version is immutable, so a change to the definition takes two applies: one
  # with `true` to create the next version as a draft, then one with `false` to release it.
  bbd_draft = false
}
