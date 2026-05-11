# Part 3 — Sandbox Landing Zone

**Kit module:** [`kit/azure/landingzones/sandbox`](../../../../../kit/azure/landingzones/sandbox)
**Foundation stack:** [`landingzones/sandbox/terragrunt.hcl`](../landingzones/sandbox/terragrunt.hcl)

## What it provisions

The sandbox landing zone creates a dedicated **Management Group** for sandbox workloads under
`f222193a-d923-4193-a924-68cd35fc7f41`, with isolation policies that prevent sandbox subscriptions from
interacting with production networks:

```
Parent MG: f222193a-d923-4193-a924-68cd35fc7f41
  └── sandbox MG: a988ed5e-ee06-424b-adb1-343fc20f2e9c
        └── (sandbox subscriptions provisioned by meshStack)
```

[`kit/azure/landingzones/sandbox/main.tf`](../../../../../kit/azure/landingzones/sandbox/main.tf):

```hcl
resource "azurerm_management_group" "sandbox" {
  display_name               = var.name
  parent_management_group_id = var.parent_management_group_id
}

module "policy_sandbox" {
  source              = "github.com/meshcloud/collie-hub//kit/azure/util/azure-policies?ref=ef06c8d"
  policy_path         = "${path.module}/lib"
  management_group_id = azurerm_management_group.sandbox.id
  location            = var.location
}
```

## Live state

```
Sandbox Management Group : a988ed5e-ee06-424b-adb1-343fc20f2e9c
  ID                     : /providers/Microsoft.Management/managementGroups/a988ed5e-ee06-424b-adb1-343fc20f2e9c
Parent Landing Zones MG  : f222193a-d923-4193-a924-68cd35fc7f41
  ID                     : /providers/Microsoft.Management/managementGroups/f222193a-d923-4193-a924-68cd35fc7f41
```

> **Portal:**
> - [a988ed5e-ee06-424b-adb1-343fc20f2e9c Management Group](https://portal.azure.com/#view/Microsoft_Azure_ManagementGroups/ManagmentGroupDrilldownMenuBlade/~/overview/tenantId/703c8d27-13e0-4836-8b2e-8390c588cf80/mgId/a988ed5e-ee06-424b-adb1-343fc20f2e9c)
> - [Policy Assignments on a988ed5e-ee06-424b-adb1-343fc20f2e9c](https://portal.azure.com/#view/Microsoft_Azure_ManagementGroups/ManagmentGroupDrilldownMenuBlade/~/policyAssignments/tenantId/703c8d27-13e0-4836-8b2e-8390c588cf80/mgId/a988ed5e-ee06-424b-adb1-343fc20f2e9c)

## Guardrail: Deny cross-subscription VNet peering

The sandbox policy set includes a custom policy definition that **denies VNet peering across
subscriptions**. This ensures sandbox environments remain isolated — developers can experiment
freely without accidentally connecting to production networks.

[`kit/azure/landingzones/sandbox/lib/policy_definitions/policy_definition_es_deny_vnet_peer_cross_sub.json`](../../../../../kit/azure/landingzones/sandbox/lib/policy_definitions/policy_definition_es_deny_vnet_peer_cross_sub.json):

```json
{
  "displayName": "Deny vNet peering cross subscription.",
  "description": "This policy denies the creation of vNet Peerings outside of the same
                  subscriptions under the assigned scope.",
  "policyRule": {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Network/virtualNetworks/virtualNetworkPeerings"
        },
        {
          "field": "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/remoteVirtualNetwork.id",
          "notcontains": "[subscription().id]"
        }
      ]
    },
    "then": {
      "effect": "Deny"
    }
  }
}
```

## Talking points

- **Purpose-built landing zone** — the sandbox MG is a guardrailed environment for a specific
  use case, just like the Bedrock OU in the AWS demo. Both demonstrate that platform teams should
  create dedicated environments with tailored guardrails instead of a one-size-fits-all approach.
- **Network isolation by policy** — instead of relying on developers to "not peer" their VNets,
  the platform team enforces isolation via Azure Policy. This is the Azure equivalent of AWS SCPs
  denying specific API actions in the Bedrock OU.
- **Self-service via meshStack** — when a developer requests a sandbox subscription through
  meshStack, it is automatically placed under this MG and all sandbox policies apply immediately.
  No manual work by the platform team.
- **Azure Policies vs. AWS SCPs** — both serve as preventive guardrails. Azure Policies offer
  more granular conditions (resource properties, field-level matching) while SCPs operate at the
  IAM API level. The effect is the same: deny actions that violate platform standards.
- **Extending the portfolio** — just like the AWS demo's Bedrock landing zone extends the four
  classic use cases, this sandbox LZ shows how platform teams continuously add new landing zone
  types as needs evolve. Other Azure LZs in this repo include `cloud-native`, `corp-online`,
  `container-platform`, and `lift-and-shift`.

## Proposed demo change — Add cost guardrail for sandbox

**Why:** Sandbox environments should have a spending limit to prevent runaway costs from
experiments. This shows how Azure Policies can enforce cost-related guardrails.

### Step 1 (kit): add a deny policy for expensive VM SKUs

Create a new policy definition in
[`kit/azure/landingzones/sandbox/lib/policy_definitions/`](../../../../../kit/azure/landingzones/sandbox/lib/policy_definitions/):

```json
{
  "name": "Deny-Expensive-VM-SKUs",
  "properties": {
    "displayName": "Deny expensive VM SKUs in sandbox",
    "description": "Prevents deployment of expensive VM families (E, M, N-series GPU) in sandbox subscriptions.",
    "policyRule": {
      "if": {
        "allOf": [
          { "field": "type", "equals": "Microsoft.Compute/virtualMachines" },
          { "field": "Microsoft.Compute/virtualMachines/sku.name",
            "like": "Standard_[EMN]*" }
        ]
      },
      "then": { "effect": "Deny" }
    }
  }
}
```

### Step 2: add the policy to the sandbox policy set

Include `Deny-Expensive-VM-SKUs` in the sandbox policy set definition and assignment.
