remote_state {
  backend = "gcs"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket = "meshcloud-tf-states"
    prefix = "${basename(get_repo_root())}/${trimprefix(get_terragrunt_dir(), "${get_repo_root()}/")}"
  }
}
