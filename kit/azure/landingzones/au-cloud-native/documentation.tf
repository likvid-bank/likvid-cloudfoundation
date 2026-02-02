output "documentation_md" {
  value = <<EOF
# Cloud-Native Landing Zone with a Administrative Unit

This landing zone is intended for cloud-native workloads.

It is using a [Administrative Unit](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/administrative-units)

Application teams using this landing zones are responsible
for all of their workloads following the "you build it, you run it" principle.

## Active Policies

This landing zone does currently not impose any additional policies or restrictions on Subscriptions or Resources
apart from those that already apply at the [organization level](../azure-organization-hierarchy.md).

The resource hierarchy of this landing zone looks like this:

```md
`${resource.azurerm_management_group.au-cloudnative.display_name}` management group for cloud-native landing zone
  └── *application team subscriptions*
```

EOF
}
