# Oracle Platform - Azure AD SAML SSO

Single Sign-On integration between Azure AD and Oracle Cloud Infrastructure using SAML federation.

## What This Module Does

✅ **Automated:**
- Creates Azure AD Enterprise Application with SAML config
- Creates Azure AD groups: `OCI-Administrators`, `OCI-Users`
- Creates OCI groups: `OCI-Administrators`, `OCI-Users`
- Configures OCI IAM policies for federated users
- Generates SAML metadata URL

❌ **Manual Setup Required:**
- SAML Identity Provider in OCI Console (due to [OCI Provider Bug #2072](https://github.com/oracle/terraform-provider-oci/issues/2072))
- Attribute mappings in OCI IdP
- Group mappings in OCI IdP

## Prerequisites

### Azure AD
- Azure AD tenant with admin access
- Permissions to create Enterprise Applications
- Azure CLI or Service Principal credentials

### OCI
- Identity Domain enabled (not available in free tier)
- Domain OCID: `ocid1.domain.oc1..aaaaaaaarluxawvelfgdkymjx5xobeqmgkco5g4zk5apsadyq2xp3yhb3u6a`
- OCI API credentials configured (`~/.oci/config`)

### Authentication Setup

**Azure AD Authentication:**

Option 1 - Azure CLI (Development):
```bash
az login
```

Option 2 - Service Principal (Production):
```bash
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="your-secret"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

**OCI Authentication:**

Configure `~/.oci/config`:
```ini
[DEFAULT]
user=ocid1.user.oc1..aaaaaaaa...
fingerprint=aa:bb:cc:dd:ee:ff...
tenancy=ocid1.tenancy.oc1..aaaaaaaa...
region=eu-frankfurt-1
key_file=~/.oci/oci_api_key.pem
```

## Deployment Steps

### 1. Authenticate to Azure AD

```bash
az login
```

Or set Service Principal credentials as shown above.

### 2. Deploy via Terragrunt

```bash
cd platforms/oracle/sso
terragrunt apply
```

This creates:
- Azure AD Enterprise Application
- Azure AD groups (automatically)
- OCI groups (automatically)
- OCI IAM policies

### 3. Complete Manual Setup

Follow the instructions in the Terraform output:

```bash
terragrunt output manual_setup_instructions
```

**Summary of manual steps:**
1. Download Azure AD metadata from output URL
2. Get Azure AD group Object IDs via `az ad group show`
3. Create SAML IdP in OCI Console with metadata + mappings
4. Configure Entity ID and Reply URL in Azure AD

**Detailed guide:** See [upstream module documentation](https://github.com/meshcloud/terraform-custom-meshplatform-sso/blob/main/examples/oci/README.md#manual-configuration-steps)

### 4. Test SSO

```bash
# Get SSO URL after manual setup
terragrunt output oci_sso_url
```

Open in incognito browser and test login with Azure AD credentials.

## Configuration

Edit `terragrunt.hcl` to customize:

```hcl
inputs = {
  # Azure AD Configuration
  azure_ad_app_name             = "OCI Cloud SSO"
  azure_ad_admin_group_name     = "OCI-Administrators"
  azure_ad_developer_group_name = "OCI-Users"

  # OCI Configuration
  oci_admin_group_name     = "OCI-Administrators"
  oci_developer_group_name = "OCI-Users"

  # IAM Policies
  create_oci_policies = true
  oci_policy_statements = [
    "Allow group 'Default'/'OCI-Administrators' to manage all-resources in tenancy",
  ]
}
```

## Architecture

```
Azure AD                          OCI
┌─────────────────┐              ┌──────────────────┐
│ Enterprise App  │              │ Identity Domain  │
│ "OCI Cloud SSO" │              │                  │
│                 │              │ SAML IdP         │
│ Groups:         │              │ (manual setup)   │
│ - OCI-Admins    │─────SAML────▶│                  │
│ - OCI-Users     │  Assertion   │ Groups:          │
│                 │              │ - OCI-Admins     │
│ Metadata URL    │              │ - OCI-Users      │
│ (auto-gen)      │              │                  │
└─────────────────┘              └──────────────────┘
```

## Module Source

This module uses the [terraform-custom-meshplatform-sso](https://github.com/meshcloud/terraform-custom-meshplatform-sso) modules, pinned to commit `0a0b239d23d65a798e9bf71fb1cfca448149f619`.

### Upstream Modules
- `azuread-saml-app`: Creates Azure AD Enterprise Application
- `oci-saml-sso`: Creates OCI groups and IAM policies

## Troubleshooting

### "Identity Provider cannot be created"
**Expected** - Due to OCI provider bug #2072. Follow manual setup instructions.

### "Authentication failed"
**Azure AD:**
- Run `az login` or verify Service Principal credentials
- Check `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID` environment variables

**OCI:**
- Verify `~/.oci/config` file exists and is configured correctly
- Check OCI API key permissions

### "Group not found in Azure AD"
The module automatically creates Azure AD groups. If you see this error:
- Check Azure AD permissions
- Verify group names in `terragrunt.hcl`

### "Cannot access Identity Domain"
- Verify Identity Domain OCID is correct
- Check OCI permissions for domain access
- Ensure Identity Domains is enabled (not available in free tier)

## Outputs

After deployment, access outputs:

```bash
terragrunt output azure_ad_app_id
terragrunt output azure_ad_metadata_url
terragrunt output azure_ad_created_groups
terragrunt output oci_created_groups
terragrunt output manual_setup_instructions
```

## References

- [Upstream Module Repository](https://github.com/meshcloud/terraform-custom-meshplatform-sso)
- [OCI SAML SSO Example](https://github.com/meshcloud/terraform-custom-meshplatform-sso/blob/main/examples/oci/README.md)
- [Azure AD SAML Module Docs](https://github.com/meshcloud/terraform-custom-meshplatform-sso/blob/main/modules/azuread-saml-app/README.md)
- [OCI SAML Module Docs](https://github.com/meshcloud/terraform-custom-meshplatform-sso/blob/main/modules/oci-saml-sso/README.md)
- [OCI Provider Bug #2072](https://github.com/oracle/terraform-provider-oci/issues/2072)
- [Oracle Docs: Azure AD SSO with OCI IAM](https://docs.oracle.com/en-us/iaas/Content/Identity/tutorials/azure_ad/jit_azure/azure_jit.htm)

## Support

For issues with the SSO modules, see the [upstream repository](https://github.com/meshcloud/terraform-custom-meshplatform-sso/issues).

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azuread_saml_app"></a> [azuread\_saml\_app](#module\_azuread\_saml\_app) | git::https://github.com/meshcloud/terraform-custom-meshplatform-sso.git//modules/azuread-saml-app | 0a0b239d23d65a798e9bf71fb1cfca448149f619 |
| <a name="module_oci_saml_sso"></a> [oci\_saml\_sso](#module\_oci\_saml\_sso) | git::https://github.com/meshcloud/terraform-custom-meshplatform-sso.git//modules/oci-saml-sso | 0a0b239d23d65a798e9bf71fb1cfca448149f619 |

## Resources

| Name | Type |
|------|------|
| [oci_identity_domain.target](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_domain) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_ad_admin_group_name"></a> [azure\_ad\_admin\_group\_name](#input\_azure\_ad\_admin\_group\_name) | Azure AD group name for administrators | `string` | n/a | yes |
| <a name="input_azure_ad_app_name"></a> [azure\_ad\_app\_name](#input\_azure\_ad\_app\_name) | Display name for the Azure AD Enterprise Application | `string` | `"OCI Cloud SSO"` | no |
| <a name="input_azure_ad_developer_group_name"></a> [azure\_ad\_developer\_group\_name](#input\_azure\_ad\_developer\_group\_name) | Azure AD group name for developers | `string` | n/a | yes |
| <a name="input_create_oci_policies"></a> [create\_oci\_policies](#input\_create\_oci\_policies) | Create IAM policies for federated users | `bool` | `true` | no |
| <a name="input_oci_admin_group_name"></a> [oci\_admin\_group\_name](#input\_oci\_admin\_group\_name) | Name of the OCI administrators group | `string` | `"OCI-Administrators"` | no |
| <a name="input_oci_compartment_id"></a> [oci\_compartment\_id](#input\_oci\_compartment\_id) | OCI Compartment/Tenancy OCID for IAM policies | `string` | n/a | yes |
| <a name="input_oci_developer_group_name"></a> [oci\_developer\_group\_name](#input\_oci\_developer\_group\_name) | Name of the OCI users/developers group | `string` | `"OCI-Users"` | no |
| <a name="input_oci_identity_domain_id"></a> [oci\_identity\_domain\_id](#input\_oci\_identity\_domain\_id) | OCI Identity Domain OCID | `string` | n/a | yes |
| <a name="input_oci_policy_statements"></a> [oci\_policy\_statements](#input\_oci\_policy\_statements) | OCI IAM policy statements for federated users | `list(string)` | `[]` | no |
| <a name="input_oci_region"></a> [oci\_region](#input\_oci\_region) | OCI region | `string` | n/a | yes |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | Organization name (used in resource naming) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_ad_app_id"></a> [azure\_ad\_app\_id](#output\_azure\_ad\_app\_id) | Azure AD Application ID |
| <a name="output_azure_ad_created_groups"></a> [azure\_ad\_created\_groups](#output\_azure\_ad\_created\_groups) | Azure AD groups created by the module |
| <a name="output_azure_ad_metadata_url"></a> [azure\_ad\_metadata\_url](#output\_azure\_ad\_metadata\_url) | Azure AD SAML Metadata URL (download and upload to OCI Console) |
| <a name="output_manual_setup_instructions"></a> [manual\_setup\_instructions](#output\_manual\_setup\_instructions) | Instructions for completing manual OCI IdP setup |
| <a name="output_oci_created_groups"></a> [oci\_created\_groups](#output\_oci\_created\_groups) | OCI groups created for federated users |
| <a name="output_oci_idcs_endpoint"></a> [oci\_idcs\_endpoint](#output\_oci\_idcs\_endpoint) | OCI Identity Domain endpoint URL |
| <a name="output_oci_sso_url"></a> [oci\_sso\_url](#output\_oci\_sso\_url) | OCI SSO URL (available after manual IdP setup) |
<!-- END_TF_DOCS -->