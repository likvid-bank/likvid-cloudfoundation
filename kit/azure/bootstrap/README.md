---
name: Azure Bootstrap
summary: |
  creates a service principal with permissions to deploy the cloud foundation infrastructure.
  This is a "bootstrap" module, which means that it must be manually executed once by an administrator
  to bootstrap the cloudfoundation.
cfmm:
  - block: iam/privileged-access-management
    description: |
      creates a service principal with permissions to deploy the cloud foundation infrastructure and secure access
      to that service principal's credentials with an AAD group. This AAD group is used to grant platform engineers
      permission to deploy the cloud foundation infrastructure.
---

# Azure Bootstrap

This documentation is intended as a reference documentation for cloud foundation or platform engineers using this module.

## Terraform State Storage

This module includes configuration to set up a state backend using Azure blob storage.
You can activate this by configuring the `terraform_state_storage` variable.

Like all bootstrap modules published on collie hub, you will need to deploy this module twice to complete the bootstrap process.
To migrate the state, it may be necessary to logout once from the Azure CLI `az logout` and then login again `az login` to obtain the newly created permissions for the storage container.
Please see the [bootstrap tutorial](https://collie.cloudfoundation.org/tutorial/deploy-first-module.html#bootstrap-a-cloud-platform) for more info.

> If you're not using `terraform_state_storage`, please configure your own backend in `platform.hcl`

## Platform Engineers Group

This module sets up an AAD group for managing platform engineers. This is required in conjunction with
enabling access to terraform state storage but can also be used to grant administrative access to Azure resources.

### UPN handling for AAD Guest users

Useful if you need to translate emails into UPNs (User Principal Names) as necessary, especially for guest users.
You can add this code block to your terragrunt.hcl file instead of using inputs."

```hcl
locals {
upn_domain = "#EXT#@devmeshithesheep.onmicrosoft.com"
  platform_engineers_emails = [
    "meshi@meshithesheep.io" # #TODO change, enter PLATFORM ENGINEERS here
  ]

# change the upn_domain value above
  platform_engineers_members = [
    for x in local.platform_engineers_emails : {
      email = x
      upn   = "${replace(x, "@", "_")}${local.upn_domain}"
    }
  ]
}
```

## Remove Bootstrap (Unbootstraping)

The following sequence must be followed in order to remove the boostrap

>Delete the tfstates-config file. The platform.hcl is using the local backend
```bash
rm foundations/<foundationname>/platforms/<platformname>/tfstates-config.yml
```
>Migrate the state from the Storage account back to your local machine
```bash
collie foundation deploy --bootstrap -- init -migrate-state
```
>Destroy the bootsrap
```bash
collie foundation deploy --bootstrap -- destroy
```

<!-- BEGIN_TF_DOCS -->
aad_tenant_id              = ""
platform_engineers_group   = "cloudfoundation-platform-engineers"
platform_engineers_members = ""
terraform_state_storage    = ""
uami_documentation_issuer  = "https://token.actions.githubusercontent.com"
uami_documentation_name    = "cloudfoundation_tf_docs_user"
uami_documentation_spn     = false
uami_documentation_subject = ""
<!-- END_TF_DOCS -->
