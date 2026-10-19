# Hub building-block coordinates — single source of truth for both the
# deployment (main.tf, via terragrunt input) and the e2e smoke test.
locals {
  module = "stackit/storage-bucket"

  # A branch, not a sha: meshStack clones it on every run, so a push reaches the next run of this
  # draft definition without a local apply. It carries a deliberately broken bucket policy for the
  # demo; demo/agentic-peng-solution holds the test and the fix.
  git_ref   = "demo/agentic-peng"
  bbd_draft = true
}
