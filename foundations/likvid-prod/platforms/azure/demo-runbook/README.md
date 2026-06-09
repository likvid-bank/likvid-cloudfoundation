# Azure Landing Zone Workshop — Demo Runbook

> **Scope:** This runbook guides a live demo of the Likvid Bank Cloud Foundation (LCF) Microsoft Azure platform.
> It covers three landing zone capabilities deployed via the `foundations/likvid-prod/platforms/azure`
> Terragrunt stack, plus proposals for quick demonstrable changes.
>
> **Safety:** Read-only throughout. Never run `terragrunt apply` or modify any Terraform/Terragrunt files
> during the demo. All state shown below was read with `terragrunt output` (read-only).

---

## Demo Parts

The three demo capability walkthroughs are rendered as separate Markdown files from live Terraform
state. Run `terragrunt apply` in this directory to regenerate them:

| File | Capability | Source dependency |
|---|---|---|
| [`part1-management-groups.md`](part1-management-groups.md) | Management Group Hierarchy | `organization-hierarchy` |
| [`part2-logging.md`](part2-logging.md) | Centralized Logging | `logging` |
| [`part3-sandbox.md`](part3-sandbox.md) | Sandbox Landing Zone | `landingzones/sandbox` |

```bash
cd foundations/likvid-prod/platforms/azure/demo-runbook
terragrunt apply
```

---

## Background

This demo shows three capabilities of the Likvid Cloud Foundation Azure platform, all managed as IaC in this repo:

1. **Management Group hierarchy** — Management Group structure and Azure Policy assignments (`platforms/azure/organization-hierarchy`)
2. **Centralized logging** — Log Analytics Workspace with Activity Log collection and security RBAC groups (`platforms/azure/logging`)
3. **Sandbox landing zone** — a dedicated Management Group for sandbox workloads with isolation policies (`platforms/azure/landingzones/sandbox`)

---

## Prerequisites

```bash
# Azure CLI login
az login --tenant 703c8d27-13e0-4836-8b2e-8390c588cf80
```

Azure Portal: **<https://portal.azure.com>** — ensure you are signed into the `703c8d27-13e0-4836-8b2e-8390c588cf80` tenant. All console links below require this tenant to be active in your browser session.

State is stored in an Azure Storage Account backend configured via `tfstates-config.yml`.
Remote state key pattern: `<relative-path>.tfstate`.

---

## Repository Layout

The repo separates reusable module logic (`kit/`) from environment-specific wiring (`foundations/`).
Only folders relevant to the three demo capabilities are shown below; there is more in the tree.

```
likvid-cloudfoundation/
├── kit/azure/
│   ├── organization-hierarchy/  # [Demo 1] Management Groups, Azure Policy
│   ├── logging/                 # [Demo 2] Log Analytics Workspace, Activity Log
│   └── landingzones/
│       └── sandbox/             # [Demo 3] Sandbox Management Group + isolation policies
└── foundations/likvid-prod/platforms/azure/
    ├── platform.hcl             # Tenant ID, Subscription ID, backend config (shared)
    ├── organization-hierarchy/  # [Demo 1] → kit/azure/organization-hierarchy
    ├── logging/                 # [Demo 2] → kit/azure/logging
    ├── landingzones/
    │   └── sandbox/             # [Demo 3] → kit/azure/landingzones/sandbox
    └── demo-runbook/            # This module — renders demo part Markdown files
```

**Key design principle:** `kit/` defines *what* to build; `foundations/` defines *where* with
environment-specific inputs. Changes flow as Pull Requests (PRs) through `kit/` and are consumed by one or more
`foundations/` stacks — the same pattern used across AWS, Azure, Google Cloud Platform (GCP) and other clouds in this repo.

---

## Architecture at a Glance

```
Azure Management Groups
└── Tenant Root Group
    └── likvid-foundation  ← parent management group
        ├── likvid-platform
        │   ├── likvid-connectivity  → Hub VNet, Firewall, Network Watcher
        │   ├── likvid-identity      → Identity management
        │   └── likvid-management    → Management subscription (TF state, logging)
        └── likvid-landingzones
            ├── corp-online          → Corporate/online workloads
            │   └── cloudnative
            │       ├── dev          → Application team subscriptions
            │       └── prod         → Application team subscriptions
            ├── sandbox              → Sandbox subscriptions (isolated)
            ├── container-platform   → AKS workloads
            └── lift-and-shift       → Migrated workloads

Logging: Activity Log → Log Analytics Workspace (management subscription, centralized)

Azure Policies applied:
  [likvid-foundation] Allowed Locations (germanywestcentral, westeurope)
  [likvid-foundation] Deny Classic Resources
  [likvid-foundation] Deny Subnet without NSG
  [likvid-foundation] Enforce TLS/SSL
  [likvid-foundation] Enforce Key Vault Guardrails
  [sandbox]           Deny Cross-Subscription VNet Peering
```

---

## Glossary

| Acronym | Full Name | Context in this Demo |
|---|---|---|
| **ARM** | Azure Resource Manager | The deployment and management layer for Azure resources. |
| **CI** | Continuous Integration | Automated pipeline (GitHub Actions) that runs `terragrunt plan` on every pull request. |
| **CLI** | Command-Line Interface | The `az` CLI and `terragrunt` CLI are the primary tools for interacting with the platform during the demo. |
| **DRY** | Don't Repeat Yourself | The `kit/` + `foundations/` split enforces DRY: module logic lives once in `kit/`, environment-specific values live in `foundations/`. |
| **EU** | European Union | Geographical/regulatory scope for allowed locations policy. |
| **GCP** | Google Cloud Platform | Google's public cloud. The LCF `kit/` pattern is reused for GCP alongside AWS and Azure. |
| **IaC** | Infrastructure as Code | Managing cloud infrastructure via declarative code files rather than manual console clicks. |
| **LAW** | Log Analytics Workspace | Azure Monitor's central log store — collects Activity Logs, diagnostic data, and security events. |
| **LCF** | Likvid Cloud Foundation | The internal platform team and their code repository. |
| **LZ** | Landing Zone | A pre-configured cloud environment tailored for a specific application team use case. |
| **M25** | M25 Bank | A digital native bank acquired by Likvid Bank in 2024. |
| **MG** | Management Group | Azure's hierarchical container for organizing subscriptions and applying policies. |
| **NSG** | Network Security Group | Azure firewall rules applied at the subnet or NIC level. |
| **PR** | Pull Request | A code review mechanism in git for infrastructure changes. |
| **RBAC** | Role-Based Access Control | Azure's authorization system for granting permissions to users and groups. |
| **TF** | Terraform / OpenTofu | The IaC tool used to define and deploy Azure resources. |
| **TLS** | Transport Layer Security | Encryption protocol enforced by Azure Policy across all services. |
| **VNet** | Virtual Network | Azure's private network, used for hub-spoke networking and sandbox isolation. |
