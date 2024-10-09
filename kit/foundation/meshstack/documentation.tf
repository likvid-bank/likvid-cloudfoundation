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
  md_files    = fileset("${path.module}/guides", "*.md")
  md_contents = { for f in local.md_files : replace(basename(f), ".md", "") => "\n${file("${path.module}/guides/${f}")}\n" }
}

output "documentation_guides_md" {
  value = merge(local.md_contents,
    {
      "guide_gitops"           = local.guide_gitops,
      "guide_custom_platforms" = local.guide_custom_platforms
    }
  )
}
