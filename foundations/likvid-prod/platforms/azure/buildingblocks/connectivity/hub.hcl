# Hub building-block coordinates — single source of truth for both the deployment
# (terragrunt.hcl) and the e2e smoke test (e2e/terragrunt.hcl).
locals {
  module = "azure/spoke-network"

  # meshcloud/meshstack-hub#385, which fixes the integration's undeclared azure_tenant_id. Move to a
  # main commit once it merges.
  git_ref = "19d0e1ec0b8648b7110a13a99bfe93b7f0821607"

  # Released: the smoke test orders from devops-platform, and a draft is visible to its owner alone.
  #
  # A released version is immutable, so any change to the definition, a new git_ref included, takes
  # two applies: one with `true` to create the next version as a draft, then one with `false` to
  # release it. Applying a change with `false` alone fails with "released versions are immutable".
  bbd_draft = false
}
