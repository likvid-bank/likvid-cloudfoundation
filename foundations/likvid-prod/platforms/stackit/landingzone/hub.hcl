# Hub reference-architecture coordinates — single source of truth for main.tf.
locals {
  architecture = "stackit-landingzone"

  # meshstack-hub `main`, at the commit that added the STACKIT Project Starterkit (#266).
  #
  # A sha rather than a branch name, and never a sha that could be rewritten. The definitions store
  # this value in `ref_name` and in the logo URL, so the runner resolves it on every run — including a
  # building block's own teardown. Point it at a commit that later stops being reachable and every run
  # fails at `Prepare Run and download Sources`, which is how a squash of the source branch once broke
  # the deletion of blocks deployed from it.
  git_ref   = "fa1adf09f1b5c5f0347c9e9f79603f2dbae73334"
  bbd_draft = true
}
