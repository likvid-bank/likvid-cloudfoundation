# Hub building-block coordinates — single source of truth for both the
# deployment (main.tf, via terragrunt input) and the e2e smoke test.
locals {
  module = "stackit/service-account"
  # Points at feature/stackit-service-account (contains the module root, its `e2e/` folder and the
  # service_account_name validation regex). Bump to the merged main SHA once the hub PR lands.
  git_ref   = "f8ea3822ecdf5daeabb9af339c4b7790c9c13ebb"
  bbd_draft = true
}
