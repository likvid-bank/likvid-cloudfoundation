terraform {
  # This is a stack file - no source needed
}

# Configure all modules to use the same OCI backend configuration
remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket                      = "oracle-foundation-tfstate"
    key                         = "${path_relative_to_include()}/terraform.tfstate"
    region                      = "eu-frankfurt-1"
    endpoint                    = "https://frorzmy3nlek.compat.objectstorage.eu-frankfurt-1.oraclecloud.com"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite"

  contents = <<EOF
terraform {
  required_version = ">= 1.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "7.30.0"
    }
  }
}
EOF
}
