# Part 1 — Management Group Hierarchy

**Kit module:** [`kit/azure/organization-hierarchy`](../../../../../kit/azure/organization-hierarchy)
**Foundation stack:** [`organization-hierarchy/terragrunt.hcl`](../organization-hierarchy/terragrunt.hcl)

## What it provisions

```
azurerm_management_group "parent"          # "likvid-foundation" (likvid-foundation)
  ├── azurerm_management_group "platform"        # "9f9f9c7f-96ac-4d45-bc90-de6f347407b7"
  │     ├── azurerm_management_group "connectivity"   # "574b0608-7fa9-41ad-98c9-3c4c2583f602" → Hub VNet, Firewall
  │     ├── azurerm_management_group "identity"       # "0023e4f8-522a-4634-b771-5250d0cbdb91" → Identity management
  │     └── azurerm_management_group "management"     # "0cbc9f7f-45e9-4908-827a-d4b30edae974" → Management subscription
  └── azurerm_management_group "landingzones"    # "f222193a-d923-4193-a924-68cd35fc7f41"
        ├── corp-online/     (managed by corp-online kit)
        │   └── cloudnative/ (managed by cloud-native kit)
        ├── sandbox/         (managed by sandbox kit)
        ├── container-platform/
        └── lift-and-shift/
```

## Live state

```
Tenant ID                     : 703c8d27-13e0-4836-8b2e-8390c588cf80

Parent MG (likvid-foundation) : likvid-foundation
  ID                          : /providers/Microsoft.Management/managementGroups/likvid-foundation

Platform MG                   : 9f9f9c7f-96ac-4d45-bc90-de6f347407b7
  ID                          : /providers/Microsoft.Management/managementGroups/9f9f9c7f-96ac-4d45-bc90-de6f347407b7
  ├── Connectivity MG         : 574b0608-7fa9-41ad-98c9-3c4c2583f602
  │   ID                      : /providers/Microsoft.Management/managementGroups/574b0608-7fa9-41ad-98c9-3c4c2583f602
  ├── Identity MG             : 0023e4f8-522a-4634-b771-5250d0cbdb91
  │   ID                      : /providers/Microsoft.Management/managementGroups/0023e4f8-522a-4634-b771-5250d0cbdb91
  └── Management MG           : 0cbc9f7f-45e9-4908-827a-d4b30edae974
      ID                      : /providers/Microsoft.Management/managementGroups/0cbc9f7f-45e9-4908-827a-d4b30edae974

Landing Zones MG              : f222193a-d923-4193-a924-68cd35fc7f41
  ID                          : /providers/Microsoft.Management/managementGroups/f222193a-d923-4193-a924-68cd35fc7f41
```

> **Portal:**
> - [likvid-foundation Management Group hierarchy](https://portal.azure.com/#view/Microsoft_Azure_Resources/ManagmentGroupDrilldownMenuBlade/~/overview/tenantId/703c8d27-13e0-4836-8b2e-8390c588cf80/mgId/likvid-foundation/mgDisplayName/likvid-foundation/mgCanAddOrMoveSubscription~/false/mgParentAccessLevel/Not%20Authorized/defaultMenuItemId/overview/drillDownMode~/true)

## Azure Policies enforced at this level

The organization-hierarchy module assigns several Azure Policy sets at the `likvid-foundation`
management group, enforcing guardrails across the entire organization
([source](../../../../../kit/azure/organization-hierarchy/main.tf)):

### Allowed Locations

Restricts all resource and resource group creation to approved EU regions:

```json
// policy_assignment_es_deny_resource_locations
{
  "allowedLocations": ["germanywestcentral", "westeurope"]
}
```

### Deny Classic Resources

Prevents deployment of legacy (ASM) resources — only Azure Resource Manager (ARM) is allowed.

### Deny Subnet without NSG

Every subnet must have a Network Security Group attached — no unprotected subnets allowed.

### Enforce TLS/SSL

Policy set enforcing minimum TLS versions across Storage, SQL, MySQL, PostgreSQL, Redis,
App Service and Key Vault.

> **Portal:** [Policy Assignments on likvid-foundation](https://portal.azure.com/#view/Microsoft_Azure_Policy/PolicyMenuBlade.MenuView/~/Compliance/scope/%2Fproviders%2FMicrosoft.Management%2FmanagementGroups%2Flikvid-foundation)

## Talking points

- The Management Group hierarchy **mirrors Azure's Cloud Adoption Framework (CAF)** recommended
  structure — platform workloads are separated from landing zone workloads under a common root.
- **Platform vs. Landing Zones split** is the Azure equivalent of the AWS "management OU vs.
  landing zones OU" pattern shown in the AWS demo. The concept is universal across clouds.
- Azure Policies at the root MG function like **AWS Service Control Policies (SCPs)** — they
  set guardrails that no subscription underneath can circumvent.
- The `connectivity`, `identity` and `management` MGs under `platform` follow the CAF
  recommended separation of concerns for platform subscriptions.
- Unlike AWS where each landing zone is an OU with accounts, Azure uses **MGs with subscriptions**.
  The IaC pattern (`kit/` module + `foundations/` wiring) stays the same.
