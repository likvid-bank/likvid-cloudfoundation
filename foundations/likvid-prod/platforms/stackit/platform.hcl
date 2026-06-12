locals {
  cloudfoundation = "likvid"
}


# STACKIT platform modules store Terraform state in the same GCS bucket as
# the GCP platform (foundation-likvid-prod-tf-states).
# TODO: this could be moved to STACKIT S3 but we haven't figured that out yet
remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    skip_bucket_creation = true
    bucket               = "foundation-likvid-prod-tf-states"
    prefix               = "platforms/stackit/${path_relative_to_include()}"
  }
}
