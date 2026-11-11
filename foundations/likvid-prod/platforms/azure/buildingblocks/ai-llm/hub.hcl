# Hub building-block coordinates — single source of truth for the deployment (terragrunt.hcl) and a
# future e2e smoke test (e2e/terragrunt.hcl).
locals {
  module = "azure/ai-llm"

  # A commit on main: a PR head stops resolving once its branch is squash-merged and deleted.
  git_ref = "9164e6b9a24c99f9b7c845022922d0cf615b34af"

  # A draft is visible to its owning workspace alone. Release with a second apply set to `false`
  # once the first run has created the definition: a released version is immutable, so any change
  # to the definition, a new git_ref included, takes two applies, `true` and then `false`.
  bbd_draft = false
}
