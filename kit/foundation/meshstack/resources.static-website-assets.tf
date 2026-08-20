
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
# The platform ref comes from the shared data source in data.platforms.tf.
resource "meshstack_tenant" "static-website-assets" {
  metadata = {
    owned_by_project   = meshstack_project.static-website-assets.metadata.name
    owned_by_workspace = "m25-platform"
  }
  spec = {
    platform_ref     = one(data.meshstack_platforms.aws.platforms).ref
    landing_zone_ref = { name = "likvid-aws-prod" }
  }

  # Destroying or replacing this tenant runs its building block's teardown, which deletes the live AWS
  # account holding the static website S3 buckets. `platform_ref` is RequiresReplace, so a plan can ask
  # for that replacement without anyone intending it — this turns such a plan into an error.
  lifecycle {
    prevent_destroy = true
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
resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "meshstack_building_block_v2" "m25_online_banking_app_docs" {
  spec = {
    display_name = "Docs Website"

    # `target_ref.identifier` was renamed to `target_ref.name` in provider 0.20.11.
    target_ref = {
      kind = "meshWorkspace"
      name = terraform_data.meshobjects_import["workspaces/m25-online-banki.yml"].output.metadata.name
    }

    # Version 3 of the definition. This block already runs v3; the code named v2, and meshStack
    # rejects a downgrade with "Cannot downgrade Building Block from 3."
    building_block_definition_version_ref = {
      uuid = "bbe89d10-72bf-488a-a528-e8036786bc52"
    }

    inputs = {
      bucket_name = { value_string = "likvid-docs-website-${random_id.bucket_id.hex}" }
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
  aws_account_id           = meshstack_tenant.static-website-assets.spec.platform_tenant_id
  documentation_vars       = local.md_template_vars
}
