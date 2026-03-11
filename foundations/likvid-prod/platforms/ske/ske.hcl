remote_state {
  backend = "gcs"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket = "meshcloud-tf-states"
    # TODO migrate stackit/idp to ske, for now, the prefix is hardcoded
    # change this to "${basename(get_repo_root())}/${trimprefix(get_terragrunt_dir(), "${get_repo_root()}/")}" and pay attention to state migration using terragrunt init -migrate-state
    prefix = "likvid-cloudfoundation/foundations/likvid-prod/platforms/stackit/idp/${path_relative_to_include()}"
  }
}
