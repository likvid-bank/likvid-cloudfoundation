
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


module "demo_gitops" {
  source = "./demos/gitops"

  repository               = var.demo_gitops.repository
  meshstack_api_key_id     = var.demo_gitops.meshstack_api_key_id
  meshstack_api_key_secret = var.demo_gitops.meshstack_api_key_secret
  aws_sso_instance_arn     = var.demo_gitops.aws_sso_instance_arn
  aws_identity_store_id    = var.demo_gitops.aws_identity_store_id
  gha_aws_role_to_assume   = var.demo_gitops.gha_aws_role_to_assume
  aws_account_id           = meshstack_tenant.static-website-assets.spec.local_id
  documentation_vars       = local.md_template_vars
}