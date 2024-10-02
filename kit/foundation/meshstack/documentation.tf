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

## How to Write Guides

Follow these steps to write a new guide:

- **For Markdown files:** Navigate to the `guides` directory and create a new Markdown file.

-  **Use Terraform variables:** If you want to use values from your Terraform configuration in your guide, such as `local.tags.BusinessUnit`, you need to create a corresponding Terraform file in the `meshstack` directory, you can take a look who the guide_gitops.tf is working.

EOF
}


locals {
  md_files    = fileset("${path.module}/guides", "*.md")
  md_contents = { for f in local.md_files : replace(basename(f), ".md", "") => "\n${file("${path.module}/guides/${f}")}\n" }
}

output "documentation_guides_md" {
  value = merge(local.md_contents,
  { "guide_gitops" = local.guide_gitops })
}
