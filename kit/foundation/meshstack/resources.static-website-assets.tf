
resource "meshstack_project" "static-website-assets" {
  metadata = {
    name               = "static-website-assets-prod"
    owned_by_workspace = "m25-platform"
  }
  spec = {
    display_name              = "Static Website Assets"
    payment_method_identifier = "m25-platform"
    tags = {
      "environment"          = ["prod"]
      "Schutzbedarf"         = ["public"]
      "LandingZoneClearance" = ["cloud-native"]
    }
  }
}

# the project hosting the s3 buckets, part of the backplane of this service
resource "meshstack_tenant" "static-website-assets" {
  metadata = {
    owned_by_project    = meshstack_project.static-website-assets.metadata.name
    owned_by_workspace  = "m25-platform"
    platform_identifier = "aws.aws-meshstack-dev"
  }
  spec = {
    landing_zone_identifier = "likvid-aws-prod"

  }
}

resource "meshstack_project_user_binding" "static_website_assets_project_admins" {
  for_each = toset(local.m25-platform-team)

  metadata = {
    name = "static_website_assets_${each.key}"
  }

  role_ref = {
    name = "Project Admin"
  }

  target_ref = {
    owned_by_workspace = "m25-platform"
    name               = meshstack_project.static-website-assets.metadata.name
  }

  subject = {
    name = each.key
  }
}

## Application Team
resource "meshstack_building_block_v2" "m25_online_banking_app_docs" {
  spec = {
    display_name = "docs website"

    target_ref = {
      kind       = "meshWorkspace"
      identifier = terraform_data.meshobjects_import["workspaces/m25-online-banki.yml"].output.metadata.name
    }

    building_block_definition_version_ref = {
      uuid = "4dd39de2-3b2f-43c1-b8ae-584069c425ad"
    }

    inputs = {
      # note: bucket names must be globally unique, we probably should use random ids here
      bucket_name = { value_string = "likvid-docs-website" }
    }
  }
}

resource "meshstack_building_block_v2" "m25_online_banking_app_repo" {
  spec = {
    display_name = "m25-online-banking"

    target_ref = {
      kind       = "meshWorkspace"
      identifier = terraform_data.meshobjects_import["workspaces/m25-online-banki.yml"].output.metadata.name
    }

    building_block_definition_version_ref = {
      uuid = "4a09ae7f-df0b-4f24-9704-1b5fed0437f6"
    }

    inputs = {
      repo_name  = { value_string = "m25-online-banking" }
      repo_owner = { value_string = "JohannesRudolph" } # not perfect but the current definition version requires this as we don't have support for optional inputs yet
    }
  }
}

# Create environment secrets

data "github_repository" "static_website_assets" {
  name = var.static_website_assets_demo.repository

}
resource "github_actions_secret" "static_website_assets_api_key_secret" {
  repository      = data.github_repository.static_website_assets.name
  secret_name     = "BUILDINGBLOCK_API_KEY_SECRET"
  plaintext_value = var.static_website_assets_demo.api_key_secret
}

resource "github_actions_variable" "static_website_assets_api_key_id" {
  repository    = data.github_repository.static_website_assets.name
  variable_name = "BUILDINGBLOCK_API_CLIENT_ID"
  value         = var.static_website_assets_demo.api_key_id
}

resource "github_actions_variable" "static_website_assets_aws_sso_instance_arn" {
  repository    = data.github_repository.static_website_assets.name
  variable_name = "SSO_INSTANCE_ARN"
  value         = var.static_website_assets_demo.aws_sso_instance_arn
}

resource "github_actions_variable" "static_website_assets_aws_identity_store_id" {
  repository    = data.github_repository.static_website_assets.name
  variable_name = "IDENTITY_STORE_ID"
  value         = var.static_website_assets_demo.aws_identity_store_id
}

resource "github_actions_variable" "static_website_assets_aws_account_id" {
  repository    = data.github_repository.static_website_assets.name
  variable_name = "AWS_ACCOUNT_ID"
  value         = meshstack_tenant.static-website-assets.spec.local_id
}

resource "github_actions_variable" "static_website_assets_aws_role_to_assume" {
  repository    = data.github_repository.static_website_assets.name
  variable_name = "AWS_ROLE_TO_ASSUME"
  value         = var.static_website_assets_demo.gha_aws_role_to_assume
}
