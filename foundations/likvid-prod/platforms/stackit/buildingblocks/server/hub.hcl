# Hub building-block coordinates — single source of truth for the deployment (main.tf, via terragrunt
# input) and a future e2e smoke test.
locals {
  module    = "stackit/server"
  git_ref   = "312039026a5051435322a10d53ede50dc2214735"
  bbd_draft = true
}
