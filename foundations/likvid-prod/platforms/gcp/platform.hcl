

locals {
  # Ideally this should use likvid-prod instead of likvid, but is kept likvid for now to avoid breaking changes in demo
  cloudfoundation = "likvid"

  # make platform config available
  platform = yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file(".//README.md"))[0])

  pam = {
    foundation_admins    = ["jrudolph@meshcloud.io", "fnowarre@meshcloud.io", "malhussan@meshcloud.io", "hdettmer@meshcloud.io"]
    foundation_engineers = ["ckraus@meshcloud.io", "jschwandke@meshcloud.io"]
  }
}

remote_state {
  backend = "gcs"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    skip_bucket_creation = true
    bucket               = "foundation-likvid-prod-tf-states"
    prefix               = "platforms/gcp/${path_relative_to_include()}"
  }
}
