# Hub building-block coordinates — single source of truth for both the
# deployment (main.tf, via terragrunt input) and the e2e smoke test.
locals {
  module    = "stackit/storage-bucket"
  git_ref   = "6447579b2e04cfb405de6b4f9105322794db48aa"
  bbd_draft = true
}
