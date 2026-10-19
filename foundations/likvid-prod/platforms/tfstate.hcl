remote_state {
  backend = "gcs"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket = "meshcloud-tf-states"
    # Fixed repo name instead of basename(get_repo_root()): a git worktree checks out under its own
    # directory name, which would otherwise give it a separate, empty state.
    prefix = "likvid-cloudfoundation/${trimprefix(get_terragrunt_dir(), "${get_repo_root()}/")}"
  }
}
