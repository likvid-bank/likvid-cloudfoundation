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

## IAM Integration

We use prod Microsoft Entra ID (tenant: meshcloudio.onmicrosoft.com) for SSO as well as SCIM sync to this meshStack.

### SCIM SYNC

This meshStack instance has users synced from prod Microsoft Entra ID. Application creation is done through Azure bootstrap module,
and details of the application is listed in https://glowing-guacamole-8korqmy.pages.github.io/prod/platforms/azure/bootstrap.html#scim-provisioning

### SSO Integration

Users of this meshStack uses a Microsoft Entra ID application to login. Creation of this application is done through Azure bootstrap module,
and details of the application is listed in https://glowing-guacamole-8korqmy.pages.github.io/prod/platforms/azure/bootstrap.html#sso-integration
EOF
}


output "documentation_guides_md" {
  value = {
    business_platforms       = local.guide_business_platforms
    gitops                   = local.guide_gitops
    on_premises_connectivity = local.guide_on_premises_connectivity
  }
}
