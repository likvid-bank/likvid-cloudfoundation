# Hub building-block coordinates — single source of truth for the deployment (terragrunt.hcl) and a
# future e2e smoke test.
locals {
  module = "ansible/vm-hardening"

  # The head of feature/ansible-vm-hardening. Switch to the main commit once it is merged: a branch
  # commit stops resolving after a squash merge deletes the branch.
  git_ref = "993afa47fd6bda9e64cd11bdb1999dd5ec33cc4e"

  # Draft, like the server definition it depends on: a draft is visible to stackit-platform only.
  bbd_draft = false
}
