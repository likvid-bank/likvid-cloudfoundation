---
name: GCP Platform Bootstrap
summary: |
  creates a service account with permissions to deploy the cloud foundation infrastructure.
  This is a "bootstrap" module, which means that it must be manually executed once by an administrator
  to bootstrap the cloudfoundation
---

# GCP Platform Bootstrap

Service Accounts in GCP must be created in a project. This module assumes that an operator manually creates this project
and supplies it as to the module's input `foundation_project_id`.

Note: when bootstrapping, enable services first by executing `collie foundation deploy --platform gcp --bootstrap -- apply -target google_project_service.enabled_services`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | 6.12.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_identity_group.platform_engineers](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/cloud_identity_group) | resource |
| [google_cloud_identity_group_membership.platform_engineers](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/cloud_identity_group_membership) | resource |
| [google_folder_iam_member.cloudfoundation_deploy](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/folder_iam_member) | resource |
| [google_folder_iam_member.platform_engineers](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/folder_iam_member) | resource |
| [google_folder_iam_member.validation](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/folder_iam_member) | resource |
| [google_iam_workload_identity_pool.github](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/iam_workload_identity_pool) | resource |
| [google_iam_workload_identity_pool_provider.github](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_organization_iam_custom_role.cloudfoundation_deploy](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/organization_iam_custom_role) | resource |
| [google_organization_iam_member.cloudfoundation_deploy_org_policy_admin](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.cloudfoundation_deploy_org_role_admin](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.validation](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/organization_iam_member) | resource |
| [google_project_iam_custom_role.storage_metadata_viewer](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.platform_engineers](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.platform_engineers_saadmin](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.platform_engineers_wif](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.project_browser](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/project_iam_member) | resource |
| [google_project_service.enabled_services](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/project_service) | resource |
| [google_service_account.validation](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/service_account) | resource |
| [google_service_account_iam_binding.github](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/service_account_iam_binding) | resource |
| [google_storage_bucket.terraform_state](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_policy.terraform_state](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/storage_bucket_iam_policy) | resource |
| [google_folder.parent](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/data-sources/folder) | data source |
| [google_iam_policy.terraform_state](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/data-sources/iam_policy) | data source |
| [google_organization.groups_org](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/data-sources/organization) | data source |
| [google_organization.parent_org](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/data-sources/organization) | data source |
| [google_project.foundation](https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_account_id"></a> [billing\_account\_id](#input\_billing\_account\_id) | id of the billing account for projects | `string` | n/a | yes |
| <a name="input_foundation"></a> [foundation](#input\_foundation) | name of the foundation | `string` | n/a | yes |
| <a name="input_foundation_project_id"></a> [foundation\_project\_id](#input\_foundation\_project\_id) | Project ID of the GCP Project hosting foundation-level resources for this foundation | `string` | n/a | yes |
| <a name="input_github_repo_enable_tf_state_access"></a> [github\_repo\_enable\_tf\_state\_access](#input\_github\_repo\_enable\_tf\_state\_access) | allow github actions access to terraform state | `bool` | n/a | yes |
| <a name="input_github_repo_full_name"></a> [github\_repo\_full\_name](#input\_github\_repo\_full\_name) | Full name of the GitHub repo incl. owner e.g. likvid-bank/likvid-cloudfoundation | `string` | n/a | yes |
| <a name="input_parent_folder_id"></a> [parent\_folder\_id](#input\_parent\_folder\_id) | Folder if of the parent folder hosting this foundation | `string` | n/a | yes |
| <a name="input_platform_engineers_group"></a> [platform\_engineers\_group](#input\_platform\_engineers\_group) | Name of the platform engineers group | <pre>object({<br>    name    = string,<br>    members = set(string),<br>    domain  = string<br>  })</pre> | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region where to create cresources | `string` | n/a | yes |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | name of the Service Account used to deploy cloud foundation resources | `string` | `"foundation-tf-deploy-user"` | no |
| <a name="input_tf_state_bucket_name"></a> [tf\_state\_bucket\_name](#input\_tf\_state\_bucket\_name) | name of the GCS bucket to create for hosting foundation-level terraform states | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_billing_account_id"></a> [billing\_account\_id](#output\_billing\_account\_id) | n/a |
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
| <a name="output_github_actions_validation_sa_email"></a> [github\_actions\_validation\_sa\_email](#output\_github\_actions\_validation\_sa\_email) | n/a |
| <a name="output_github_actions_workload_identity_provider"></a> [github\_actions\_workload\_identity\_provider](#output\_github\_actions\_workload\_identity\_provider) | n/a |
| <a name="output_parent_folder_id"></a> [parent\_folder\_id](#output\_parent\_folder\_id) | n/a |
| <a name="output_platform_engineers_group_email"></a> [platform\_engineers\_group\_email](#output\_platform\_engineers\_group\_email) | n/a |
| <a name="output_platform_engineers_group_name"></a> [platform\_engineers\_group\_name](#output\_platform\_engineers\_group\_name) | n/a |
<!-- END_TF_DOCS -->