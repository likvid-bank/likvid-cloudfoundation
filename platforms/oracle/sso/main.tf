data "oci_identity_domain" "target" {
  domain_id = var.oci_identity_domain_id
}

module "azuread_saml_app" {
  source = "git::https://github.com/meshcloud/terraform-custom-meshplatform-sso.git//modules/azuread-saml-app?ref=0a0b239d23d65a798e9bf71fb1cfca448149f619"

  display_name    = var.azure_ad_app_name
  identifier_uris = ["${data.oci_identity_domain.target.url}/fed"]
  redirect_uris   = ["${data.oci_identity_domain.target.url}/fed/v1/sp/sso"]

  create_groups = {
    (var.azure_ad_admin_group_name) = {
      description = "Administrators for ${var.organization_name} OCI Cloud"
    }
    (var.azure_ad_developer_group_name) = {
      description = "Developers for ${var.organization_name} OCI Cloud"
    }
  }

  include_groups_claim = true
}

module "oci_saml_sso" {
  source = "git::https://github.com/meshcloud/terraform-custom-meshplatform-sso.git//modules/oci-saml-sso?ref=0a0b239d23d65a798e9bf71fb1cfca448149f619"

  identity_domain_id = var.oci_identity_domain_id
  compartment_id     = var.oci_compartment_id

  group_mappings = {
    (var.azure_ad_admin_group_name) = {
      oci_group_name = var.oci_admin_group_name
    }
    (var.azure_ad_developer_group_name) = {
      oci_group_name = var.oci_developer_group_name
    }
  }

  create_identity_policy = var.create_oci_policies
  policy_name            = "azure-ad-federated-users-${var.organization_name}"
  policy_statements      = var.oci_policy_statements
}
