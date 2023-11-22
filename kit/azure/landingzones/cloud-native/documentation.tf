output "documentation_md" {
  value  = <<EOF
# Cloud-Native Landing Zone

This landing zone is intended for cloud-native workloads. Application teams using this landing zones are responsible
for all of their workloads following the "you build it, you run it" principle.

This landing zone does currently not impose any additional policies or restrictions on Subscriptions or Resources
apart from those that already apply at the [organization level](../azure-organization-hierarchy.md).

## Dev and Prod Stage Separation

We separate development and productive workloads in the cloud-native Landing Zone via two management groups. 

> Currently the same policies apply to development and productive workloads. However, the cloud foundation team may decide
> to introduce more differences in the future.

The resource hierarchy looks like this:

```md
`${resource.azurerm_management_group.cloudnative.display_name}` cloud-native landing zone
  ├── `${resource.azurerm_management_group.dev.display_name}` development workloads
  └── `${resource.azurerm_management_group.prod.display_name}` production workloads
```

EOF
}
