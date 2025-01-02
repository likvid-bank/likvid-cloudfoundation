terraform {
  source = "${get_repo_root()}//kit/foundation/docs"
}

# note: we don't track any state for this module itself

locals {
  foundation_path    = "${get_repo_root()}/foundations/likvid-prod"
  azure_platform     = read_terragrunt_config("${local.foundation_path}/platforms/azure/platform.hcl")
  meshstack_platform = read_terragrunt_config("${local.foundation_path}/meshstack/terragrunt.hcl")

  aws_backend_config = {
    bucket   = local.meshstack_platform.locals.bucket
    region   = local.meshstack_platform.locals.region
    role_arn = local.meshstack_platform.locals.role_arn
    profile  = local.meshstack_platform.locals.profile
  }
}

inputs = {
  module_docs = [
    {
      prefix  = "platforms/azure",
      backend = "azurerm",
      config = {
        use_azuread_auth     = true
        tenant_id            = local.azure_platform.locals.platform.azure.aadTenantId,
        subscription_id      = local.azure_platform.locals.platform.azure.subscriptionId,
        resource_group_name  = local.azure_platform.locals.tfstateconfig.resource_group_name
        storage_account_name = local.azure_platform.locals.tfstateconfig.storage_account_name
        container_name       = local.azure_platform.locals.tfstateconfig.container_name
      }
    },
    {
      prefix     = "platforms/aws",
      backend    = "s3",
      key_prefix = "platforms/aws/"
      config     = local.aws_backend_config
    },
    {
      prefix     = "platforms/ionos",
      backend    = "s3",
      key_prefix = "platforms/ionos/"
      config     = local.aws_backend_config
    },
    {
      prefix     = "platforms/sapbtp",
      backend    = "s3",
      key_prefix = "platforms/sapbtp/"
      config     = local.aws_backend_config
    },

    # foundation modules
    {
      prefix  = "meshstack",
      backend = "s3",
      config  = local.aws_backend_config
    }
  ]

  foundation_dir = "${local.foundation_path}"
  template_dir   = "${local.foundation_path}/docs/vuepress"
  output_dir     = "${local.foundation_path}/.docs-v2"
  repo_dir       = "${get_repo_root()}"
}
