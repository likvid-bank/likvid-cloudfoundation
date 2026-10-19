output "azure_ad_app_id" {
  description = "Azure AD Application ID"
  value       = module.azuread_saml_app.application_id
}

output "azure_ad_metadata_url" {
  description = "Azure AD SAML Metadata URL (download and upload to OCI Console)"
  value       = module.azuread_saml_app.saml_metadata_url
}

output "azure_ad_created_groups" {
  description = "Azure AD groups created by the module"
  value       = module.azuread_saml_app.created_groups
}

output "oci_created_groups" {
  description = "OCI groups created for federated users"
  value       = module.oci_saml_sso.created_groups
}

output "oci_sso_url" {
  description = "OCI SSO URL (available after manual IdP setup)"
  value       = module.oci_saml_sso.sso_url
}

output "oci_idcs_endpoint" {
  description = "OCI Identity Domain endpoint URL"
  value       = module.oci_saml_sso.idcs_endpoint
}

output "manual_setup_instructions" {
  description = "Instructions for completing manual OCI IdP setup"
  value       = <<-EOT
    ⚠️  MANUAL SETUP REQUIRED ⚠️

    Due to OCI Terraform Provider Bug #2072 (https://github.com/oracle/terraform-provider-oci/issues/2072), the Identity Provider must be created manually.

    STEP 1: Download Azure AD Metadata
      URL: ${module.azuread_saml_app.saml_metadata_url}

      Or download via curl:
      curl -o azure-ad-metadata.xml "${module.azuread_saml_app.saml_metadata_url}"

    STEP 2: Get Azure AD Group Object IDs
      Run these commands:
      az ad group show --group "${var.azure_ad_admin_group_name}" --query id -o tsv
      az ad group show --group "${var.azure_ad_developer_group_name}" --query id -o tsv

    STEP 3: Create Identity Provider in OCI Console
      1. Navigate to: Identity & Security → Domains → Your Domain → Security → Identity providers
      2. Click "Add SAML IdP"
      3. Name: "Microsoft Azure AD"
      4. Upload metadata XML from Step 1
      5. Enable JIT Provisioning with attribute mappings:
         SAML Attribute → OCI Attribute:
         - http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress → Primary email address
         - http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname → First name
         - http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname → Last name
      6. Configure group mapping:
         - Group assertion attribute: http://schemas.microsoft.com/ws/2008/06/identity/claims/groups
         - Group assignment method: Overwrite
      7. Add group mappings using Object IDs from Step 2:
         - <admin-group-object-id> → ${var.oci_admin_group_name}
         - <developer-group-object-id> → ${var.oci_developer_group_name}
      8. Click "Finish"
      9. Activate the IdP (three dots menu → Activate)

    STEP 4: Configure Azure AD Reply URLs
      In Azure Portal → Enterprise Applications → "${var.azure_ad_app_name}" → Single sign-on → Basic SAML Configuration:
      - Identifier (Entity ID): ${data.oci_identity_domain.target.url}/fed
      - Reply URL (ACS): ${data.oci_identity_domain.target.url}/fed/v1/sp/sso

    STEP 5: Test SSO
      1. Assign test users to Azure AD groups
      2. Open SSO URL in incognito browser
      3. Verify login and JIT user creation

    Complete documentation:
    - platforms/oracle/sso/README.md
    - https://github.com/meshcloud/terraform-custom-meshplatform-sso/blob/main/examples/oci/README.md
  EOT
}
