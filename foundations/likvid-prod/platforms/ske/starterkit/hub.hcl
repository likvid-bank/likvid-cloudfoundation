# Hub building-block coordinates — single source of truth for both the deployment
# (terragrunt.hcl) and the e2e smoke test (e2e/terragrunt.hcl).
#
# `module` is only consumed by e2e/: the deployment composes three hub modules (the starter kit and
# the two definitions it creates child building blocks from), so it names their paths itself.
locals {
  module  = "ske/ske-starterkit"
  git_ref = "5543c15011ec2193c35584da6d50a5d2796d326b"

  # Released, not draft — the e2e test orders against `version_latest_release`.
  bbd_draft = false
}
