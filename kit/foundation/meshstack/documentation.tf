output "documentation_md" {
  value = <<EOF
# meshStack Configuration Reference

At Likvid Bank we use meshStack to provide cloud services to application teams.
This page documents how we set up meshStack at Likvid Bank.

## Tags and Policies

### Tags

- `${local.tags.BusinessUnit}`: on Workspaces, Landing Zones, Building Block Definitions

### Policies

| Policy                                                                              | Description                                                                         | Rationale                                         |
|-------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|---------------------------------------------------|
| `${local.policies.RestrictLandingZoneToWorkspaceBusinessUnit.policy}`               | ${local.policies.RestrictLandingZoneToWorkspaceBusinessUnit.description}            | See [Business Platforms](./meshstack/guides/business_platforms.md) |
| `${local.policies.RestrictBuildingBlockToWorkspaceBusinessUnit.policy}`             | ${local.policies.RestrictBuildingBlockToWorkspaceBusinessUnit.description}          | See [Business Platforms](./meshstack/guides/business_platforms.md) |

### Workspaces

| Workspace | Display Name |
|-----------|--------------|
${join("\n", [for k, v in local.meshobjects_files : "| ${k} | ${v.spec.displayName} |"])}

## Building Block Definitions

### GitHub Action Trigger Building Block

This Building Block triggers two GitHub Action workflows, depending on whether a Building Block is regularly applied or
destroyed. Within these actions, you can extract all information related to this Building Block Run from the provided
input. If the user permissions are provided as an input, you can optionally retrieve a list of users who have permissions
on a project.

#### Building Block Definition Implementation

In your meshStack building block definition implementation fill the following:

Git Repository URL: `git@github.com:likvid-bank/likvid-cloudfoundation.git`
Git Repository Path: `kit/github/buildingblocks/action-trigger/buildingblock`

Upload the SSH key from the output of github/buildingblocks/automation kit.

#### Building Block Definition Inputs

::: details INPUTS

> Inputs are based on M25 Static Website Assets building block in likvid-prod. It should be generic here, and specified in foundation/meshstacks when we have a BB def API, and terraform resource.

```json
[
  {
    "inputKey": "bucket_name",
    "displayName": "Bucket Name",
    "inputType": "STRING",
    "assignmentType": "USER_INPUT",
    "isEnvironment": false,
    "isSensitive": false,
    "inputValueValidationRegex": "^[a-z0-9]([a-z0-9-]{1,61}[a-z0-9])?$",
    "validationRegexErrorMessage": "Please use only alphanumeric characters and dash."
  },
  {
    "inputKey": "github_owner",
    "displayName": "Github Owner",
    "inputType": "STRING",
    "assignmentType": "STATIC",
    "argument": "meshcloud",
    "isEnvironment": false,
    "isSensitive": false,
    "selectableValues": [],
  },
  {
    "inputKey": "github_repo",
    "displayName": "Github Repo",
    "inputType": "STRING",
    "assignmentType": "STATIC",
    "argument": "static-website-assets",
    "isEnvironment": false,
    "isSensitive": false,
    "description": "GitHub Repository that contains the workflow files",
  },
  {
    "inputKey": "workflow_branch",
    "displayName": "Workflow Branch",
    "inputType": "STRING",
    "assignmentType": "STATIC",
    "argument": "main",
    "isEnvironment": false,
    "isSensitive": false,
    "description": "The branch in which the workflow files are placed, usually main.",
  },
  {
    "inputKey": "github_token",
    "displayName": "Github Token",
    "inputType": "STRING",
    "assignmentType": "STATIC",
    "argument": "<TOKEN>",
    "isEnvironment": false,
    "isSensitive": true,
    "description": "Your GitHub Personal Access Token",
  },
  {
    "inputKey": "user_permissions",
    "displayName": "User Permissions",
    "inputType": "LIST",
    "assignmentType": "USER_PERMISSIONS",
    "isEnvironment": true,
    "isSensitive": false,
    "description": "meshstack will provide the list of current users and their permissions as an input.",
  }
]
```
:::

#### Building Block Definition Outputs:

None

EOF
}

locals {
  workspaces = {
    m25_platform_team = terraform_data.meshobjects_import["workspaces/m25-platform.yml"].output
    # Add more workspaces for demo stories
    likvid_mobile      = terraform_data.meshobjects_import["workspaces/likvid-mobile.yml"].output
    m25_online_banking = terraform_data.meshobjects_import["workspaces/m25-online-banki.yml"].output
    cloud_foundation   = terraform_data.meshobjects_import["workspaces/cloud-foundation.yml"].output
  }
}

locals {
  md_files = fileset("${path.module}/guides", "*.md")
  md_contents = {
    for f in local.md_files :
    replace(basename(f), ".md", "") => templatefile("${path.module}/guides/${f}", {

      # new pattern, we generate ready to use markdown depp-links into meshpanel to entities where that makes sense
      md_workspace_m25_platform_team  = "[${local.workspaces.m25_platform_team.spec.displayName}](${var.meshpanel_base_url}/#/w/${local.workspaces.m25_platform_team.metadata.name})",
      md_workspace_likvid_mobile      = "[${local.workspaces.likvid_mobile.spec.displayName}](${var.meshpanel_base_url}/#/w/${local.workspaces.likvid_mobile.metadata.name})",
      md_workspace_m25_online_banking = "[${local.workspaces.m25_online_banking.spec.displayName}](${var.meshpanel_base_url}/#/w/${local.workspaces.m25_online_banking.metadata.name})",
      md_workspace_cloud_foundation   = "[${local.workspaces.cloud_foundation.spec.displayName}](${var.meshpanel_base_url}/#/w/${local.workspaces.cloud_foundation.metadata.name})",

      tags_BusinessUnit    = local.tags.BusinessUnit,
      tags_SecurityContact = local.tags.SecurityContact,

      meshobjects_import_workspaces_devops_platform_yml_output_spec_displayName  = terraform_data.meshobjects_import["workspaces/devops-platform.yml"].output.spec.displayName,
      buildingBlockDefinitions_github_repository_spec_displayName                = local.buildingBlockDefinitions.github-repository.spec.displayName,
      platformDefinitions_github_repository_spec_displayName                     = local.customPlatformDefinitions.github-repository.spec.displayName,
      platformDefinitions_github_repository_spec_description                     = local.customPlatformDefinitions.github-repository.spec.description,
      platformDefinitions_github_repository_spec_web_console_url                 = local.customPlatformDefinitions.github-repository.spec.web-console-url,
      platformDefinitions_github_repository_spec_support_url                     = local.customPlatformDefinitions.github-repository.spec.support-url,
      platformDefinitions_github_repository_spec_documentation_url               = local.customPlatformDefinitions.github-repository.spec.documentation-url,
      landingZones_github_repository_spec_displayName                            = local.landingZones.github-repository.spec.displayName,
      meshobjects_import_workspaces_m25_online_banki_yml_output_spec_displayName = terraform_data.meshobjects_import["workspaces/m25-online-banki.yml"].output.spec.displayName,
      meshstack_project_m25_online_banking_app_spec_display_name                 = meshstack_project.m25_online_banking_app.spec.display_name,
      meshstack_tenant_m25_online_banking_app_docs_repo_spec_local_id            = meshstack_tenant.m25_online_banking_app_docs_repo.spec.local_id
      policy_RestrictLandingZoneToWorkspaceBusinessUnit                          = local.policies.RestrictLandingZoneToWorkspaceBusinessUnit.policy,
      policy_RestrictBuildingBlockToWorkspaceBusinessUnit                        = local.policies.RestrictBuildingBlockToWorkspaceBusinessUnit.policy,
      meshobjects_import_workspaces_m25_platform_yml_output_spec_displayName     = terraform_data.meshobjects_import["workspaces/m25-platform.yml"].output.spec.displayName,
      landinZones_m25_cloud_native_spec_displayName                              = local.landingZones.m25-cloud-native.spec.displayName,
      landinZones_m25_cloud_native_spec_tags_BusinessUnit                        = "${local.tags.BusinessUnit}: ${join(", ", local.landingZones.m25-cloud-native.spec.tags.BusinessUnit)}",
      buildingBlockDefinitions_m25_domain_spec_displayName                       = local.buildingBlockDefinitions.m25-domain.spec.displayName,
      meshobjects_import_workspaces_likvid_mobile_yml_output_spec_displayName    = terraform_data.meshobjects_import["workspaces/likvid-mobile.yml"].output.spec.displayName,
      landinZones_m25_cloud_native_spec_name                                     = local.landingZones.m25-cloud-native.name
      buildingBlockDefinitions_m25_domain_spec_description                       = lower(local.buildingBlockDefinitions.m25-domain.spec.description),
      buildingBlockDefinitions_m25_domain_spec_tags_businessUnit                 = join(", ", local.buildingBlockDefinitions.m25-domain.spec.tags.BusinessUnit),
      meshobjects_import_output_spec_tags_BusinessUnit                           = join(", ", terraform_data.meshobjects_import["workspaces/m25-online-banki.yml"].output.spec.tags.BusinessUnit),
      buildingBlockDefinitions_m25-static-website-assets_spec_displayName        = local.buildingBlockDefinitions.m25-static-website-assets.spec.displayName,
      meshobjects_import_workspaces_m25-platform_yml_output_spec_displayName     = terraform_data.meshobjects_import["workspaces/m25-platform.yml"].output.spec.displayName,

      # SAP BTP Custom Platform
      meshobjects_import_workspaces_sap_core_platform_yml_output_spec_displayName = terraform_data.meshobjects_import["workspaces/sap-core-platform.yml"].output.spec.displayName,
      meshstack_project_sap_core_platform_spec_display_name                       = meshstack_project.sap_core_platform.spec.display_name,
      buildingBlockDefinitions_sapbtp_subaccounts_repository_spec_displayName     = local.buildingBlockDefinitions.sapbtp-subaccounts-repository.spec.displayName,
      landingZones_sap_core_platform_spec_displayName                             = local.landingZones.sap-core-platform.spec.displayName,
      platformDefinitions_sap_core_platform_spec_displayName                      = local.customPlatformDefinitions.sap-core-platform.spec.displayName,
      platformDefinitions_sap_core_platform_spec_description                      = local.customPlatformDefinitions.sap-core-platform.spec.description,
      platformDefinitions_sap_core_platform_spec_support_url                      = local.customPlatformDefinitions.sap-core-platform.spec.support-url,
      platformDefinitions_sap_core_platform_spec_documentation_url                = local.customPlatformDefinitions.sap-core-platform.spec.documentation-url,
      platformDefinitions_sap_core_platform_spec_web_console_url                  = local.customPlatformDefinitions.sap-core-platform.spec.web-console-url,

      # IONOS Custom Platform
      meshobjects_import_workspaces_ionos_yml_output_spec_displayName = terraform_data.meshobjects_import["workspaces/likvid-govguard.yml"].output.spec.displayName,

      meshstack_project_likvid_gov_guard_dev_spec_display_name  = meshstack_project.likvid_gov_guard_dev.spec.display_name,
      meshstack_project_likvid_gov_guard_prod_spec_display_name = meshstack_project.likvid_gov_guard_prod.spec.display_name,

      buildingBlockDefinitions_ionos_virtual_datacenter_repository_spec_displayName = local.buildingBlockDefinitions.ionos-virtual-data-center.spec.displayName,
      landingZones_ionos_dev_spec_displayName                                       = local.landingZones.ionos-dev.spec.displayName,
      landingZones_ionos_prod_spec_displayName                                      = local.landingZones.ionos-prod.spec.displayName,
      platformDefinitions_ionos_spec_displayName                                    = local.customPlatformDefinitions.ionos.spec.displayName,
      platformDefinitions_ionos_spec_description                                    = local.customPlatformDefinitions.ionos.spec.description,
      platformDefinitions_ionos_spec_support_url                                    = local.customPlatformDefinitions.ionos.spec.support-url,
      platformDefinitions_ionos_spec_documentation_url                              = local.customPlatformDefinitions.ionos.spec.documentation-url,
      platformDefinitions_ionos_spec_web_console_url                                = local.customPlatformDefinitions.ionos.spec.web-console-url,

      # stackit Custom Platform
      buildingBlockDefinitions_stackit_projects_spec_displayName = local.buildingBlockDefinitions.stackit-projects.spec.displayName,
      landingZones_stackit_dev_spec_displayName                  = local.landingZones.stackit-dev.spec.displayName,
      landingZones_stackit_prod_spec_displayName                 = local.landingZones.stackit-prod.spec.displayName,
      platformDefinitions_stackit_spec_displayName               = local.customPlatformDefinitions.stackit.spec.displayName,
      platformDefinitions_stackit_spec_description               = local.customPlatformDefinitions.stackit.spec.description,
      platformDefinitions_stackit_spec_support_url               = local.customPlatformDefinitions.stackit.spec.support-url,
      platformDefinitions_stackit_spec_documentation_url         = local.customPlatformDefinitions.stackit.spec.documentation-url,
      platformDefinitions_stackit_spec_web_console_url           = local.customPlatformDefinitions.stackit.spec.web-console-url,

      # Quickstart AWS
      meshstack_project_quickstart_aws_spec_display_name           = meshstack_project.quickstart.spec.display_name,
      meshstack_tenant_quickstart_aws_spec_landing_zone_identifier = meshstack_tenant.quickstart_aws.spec.landing_zone_identifier,
      meshstack_tenant_quickstart_aws_spec_local_id                = meshstack_tenant.quickstart_aws.spec.local_id,

      # API and platform URLs for demo stories
      meshstack_api_url = var.meshstack_api.endpoint,
      meshpanel_url     = var.meshpanel_base_url
    })
  }
}

output "documentation_guides_md" {
  value = local.md_contents
}
