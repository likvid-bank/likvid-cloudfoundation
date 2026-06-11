# STACKIT platform modules store Terraform state in the same GCS bucket as
# the GCP platform (foundation-likvid-prod-tf-states) rather than the
# meshcloud-internal bucket (meshcloud-tf-states). This keeps state in a
# bucket that is owned and managed by this repo (via platforms/gcp/bootstrap)
# and accessible to the CI service account (likvid-foundation-gha) without
# requiring additional IAM grants on meshcloud-internal infrastructure.
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
