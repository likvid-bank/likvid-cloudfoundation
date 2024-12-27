# SAP BTP subaccount with environment configuration

This building block Creates a subaccount in SAP BTP.

## How to use this Building Block in meshStack

1. Go to your meshStack admin area and click on "Building Blocks" from the left pane
2. Click on "Create Building Block"
3. Fill out the general information and click next
4. Select any of the platforms as your supported platform to attach this building block to.
5. Select "Terraform" in Implementation Type and put in the Terraform version
6. Copy the repository HTTPS address to the "Git Repository URL" field (if its a private repo, add your SSH key) click next
7. For the inputs do the following
    - Backend configuration:
        - Select "File" as input type and upload the backend.tf file.
        - Add related environment variables based on your backend configuration (e.g. client_id and client_secret for azure, SA_ID and SA_EMAIL for GCS)
    - SAP Account Variables:
        - BTP_USERNAME and BTP_PASSWORD as Environment variable
    - Add rest of the variables in variables.tf as you desired
8. On the next page, add the outputs from outputs.tf file and click on Create Building Block
9. Now users can add this building block to their tenants

## Backend configuration

Here you can find an example of how to create a backend.tf file on this [Wiki Page](https://github.com/meshcloud/building-blocks/wiki/%5BUser-Guide%5D-Setting-up-the-Backend-for-terraform-state#how-to-configure-backendtf-file-for-these-providers)
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.65.0 |
| <a name="requirement_btp"></a> [btp](#requirement\_btp) | ~> 1.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [btp_subaccount.subaccount](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount) | resource |
| [btp_subaccount_role_collection_assignment.subaccount_admin](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_role_collection_assignment) | resource |
| [btp_subaccount_role_collection_assignment.subaccount_service_admininstrator](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_role_collection_assignment) | resource |
| [btp_subaccount_role_collection_assignment.subaccount_viewer](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_role_collection_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | this is for the tfstates Backend. in our case AWS. | `string` | n/a | yes |
| <a name="input_globalaccount"></a> [globalaccount](#input\_globalaccount) | The subdomain of the global account in which you want to manage resources. | `string` | n/a | yes |
| <a name="input_parent_id"></a> [parent\_id](#input\_parent\_id) | The ID of the parent resource. | `string` | n/a | yes |
| <a name="input_project_identifier"></a> [project\_identifier](#input\_project\_identifier) | The meshStack project identifier. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region of the subaccount. | `string` | `"eu30"` | no |
| <a name="input_users"></a> [users](#input\_users) | Users and their roles provided by meshStack | <pre>list(object(<br>    {<br>      meshIdentifier = string<br>      username       = string<br>      firstName      = string<br>      lastName       = string<br>      email          = string<br>      euid           = string<br>      roles          = list(string)<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_workspace_identifier"></a> [workspace\_identifier](#input\_workspace\_identifier) | The meshStack workspace identifier. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_btp_subaccount_id"></a> [btp\_subaccount\_id](#output\_btp\_subaccount\_id) | n/a |
| <a name="output_btp_subaccount_login_link"></a> [btp\_subaccount\_login\_link](#output\_btp\_subaccount\_login\_link) | n/a |
| <a name="output_btp_subaccount_name"></a> [btp\_subaccount\_name](#output\_btp\_subaccount\_name) | n/a |
| <a name="output_btp_subaccount_region"></a> [btp\_subaccount\_region](#output\_btp\_subaccount\_region) | n/a |
<!-- END_TF_DOCS -->