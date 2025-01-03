output "documentation_md" {
  value = <<EOF
# Organization Hierarchy

All resources of this platform are nested under the top-level GCP folder `${data.google_folder.parent.display_name}`.
All policies described below are also set at this folder level.

```
${data.google_folder.parent.display_name}
  └── ${google_folder.admin.display_name}
  └── ${google_folder.dev.display_name}
  └── ${google_folder.prod.display_name}
  └── ${google_folder.data_lagoon.display_name}
```

### Domain Restricted Sharing

::: tip Domain Restricted Sharing
[Domain Restricted Sharing](https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains) restricts the set of identities that are allowed to be used in Identity and Access Management policies.
This prevents access to resources in this organization by any foreign identities.
:::

Note that this setting will prevent using public access (e.g. on GCS buckets) by default as well.

The allowed domains are

${join("\n", formatlist("- %s (Customer Id `%s`)", local.resolved_customer_ids_to_allow[*].domain, local.resolved_customer_ids_to_allow[*].customer_id))}

### Resource Locations

::: tip Resource Locations
[Resource Locations](https://cloud.google.com/resource-manager/docs/organization-policy/defining-locations) restrics deployment of resources to whitelisted regions.
This prevents deployment of resources outside of approved locations.
:::

The allowed resource locations are

${join("\n", formatlist("- `%s`", var.resource_locations_to_allow))}

EOF
}
