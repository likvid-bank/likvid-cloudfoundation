# Hub reference-architecture coordinates — single source of truth for main.tf.
locals {
  architecture = "stackit-landingzone"

  # Head of meshstack-hub PR #266 (`feature/stackit-project-starterkit`), which adds the STACKIT
  # Project Starterkit. A sha rather than the branch name on purpose: the definitions store this value
  # in `ref_name` and in the logo URL, so a branch would let a later push change what a deployed
  # definition points at. Repin to the merged sha once #266 lands.
  git_ref   = "fa1adf09f1b5c5f0347c9e9f79603f2dbae73334"
  bbd_draft = true
}
