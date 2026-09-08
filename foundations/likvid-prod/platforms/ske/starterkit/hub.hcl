# Hub building-block coordinates — single source of truth for both the deployment
# (terragrunt.hcl) and the e2e smoke test (e2e/terragrunt.hcl).
#
# `module` is only consumed by e2e/: the deployment composes three hub modules (the starter kit and
# the two definitions it creates child building blocks from), so it names their paths itself.
locals {
  module  = "ske/ske-starterkit"
  git_ref = "7d33e78a6dd3f004559d45fee62aecf2774a2274"

  # Draft, so dependent building blocks can be upgraded in place.
  bbd_draft = true
}
