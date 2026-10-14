# Hub building-block coordinates — single source of truth for the deployment (main.tf, via terragrunt
# input) and a future e2e smoke test.
locals {
  module = "stackit/server"

  # A commit on main: a PR head stops resolving once its branch is squash-merged and deleted.
  git_ref = "85f2f908b9f11843aebdb6c889788dd11a320153"

  bbd_draft = false
}
