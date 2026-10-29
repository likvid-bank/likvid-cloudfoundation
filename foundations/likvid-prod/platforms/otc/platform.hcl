locals {
  cloudfoundation = "likvid"
}

# T Cloud Public platform modules store Terraform state in the same GCS bucket as the GCP and STACKIT
# platforms (foundation-likvid-prod-tf-states).
remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    skip_bucket_creation = true
    bucket               = "foundation-likvid-prod-tf-states"
    prefix               = "platforms/otc/${path_relative_to_include()}"
  }
}
