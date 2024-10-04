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
