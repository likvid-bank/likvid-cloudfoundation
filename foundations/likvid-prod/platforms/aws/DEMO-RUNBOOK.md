# AWS Landing Zone Workshop — Demo Runbook

> **Scope:** This runbook guides a live demo of the Likvid Bank Cloud Foundation (LCF) Amazon Web Services (AWS) platform.
> It covers three landing zone capabilities deployed via the `foundations/likvid-prod/platforms/aws`
> Terragrunt stack, plus proposals for quick demonstrable changes.
>
> **Safety:** Read-only throughout. Never run `terragrunt apply` or modify any Terraform/Terragrunt files
> during the demo. All state shown below was read with `terragrunt output` (read-only).

---

## Background

This demo shows three capabilities of the Likvid Cloud Foundation AWS platform, all managed as IaC in this repo:

1. **Organization hierarchy** — Organizational Unit (OU) structure, management accounts and Service Control Policies (SCPs) (`platforms/aws/organization`)
2. **Centralized audit logs** — org-wide CloudTrail writing to a locked-down Simple Storage Service (S3) bucket (`platforms/aws/organization-trail`)
3. **Bedrock landing zone** — a dedicated OU for Generative AI (GenAI) workloads provisioned via an external meshstack-hub module (`platforms/aws/landingzones/bedrock`)

---

## Prerequisites

```bash
# SSO login (token valid ~8 hours)
aws sso login --profile likvid
```

SSO start page: **<https://meshcloud-dev.awsapps.com/start>** — select the `702461728527` management account for console access. All console links below require this account to be active in your browser session.

State is stored in an S3 bucket `likvid-tf-state` (eu-central-1) in automation account `302263042172`.
Remote state key pattern: `platforms/aws/<relative-path>.tfstate`.

---

## Repository Layout

The repo separates reusable module logic (`kit/`) from environment-specific wiring (`foundations/`).
Only folders relevant to the three demo capabilities are shown below; there is more in the tree.

```
likvid-cloudfoundation/
├── kit/aws/
│   ├── organization/        # [Demo 1] OU hierarchy, management accounts, SCPs
│   ├── organization-trail/  # [Demo 2] Organization-wide CloudTrail + audit S3 bucket

│   └── landingzones/
│       └── (bedrock via external meshstack-hub module)  # [Demo 3]
└── foundations/likvid-prod/platforms/aws/
    ├── platform.hcl         # Account IDs, SSO profile, S3 backend (shared config)
    ├── organization/        # [Demo 1] → kit/aws/organization
    ├── organization-trail/  # [Demo 2] → kit/aws/organization-trail
    └── landingzones/
        └── bedrock/         # [Demo 3] → meshstack-hub agentic-coding-sandbox
```

**Key design principle:** `kit/` defines *what* to build; `foundations/` defines *where* with
environment-specific inputs. Changes flow as Pull Requests (PRs) through `kit/` and are consumed by one or more
`foundations/` stacks — the same pattern used across AWS, Azure, Google Cloud Platform (GCP) and other clouds in this repo.

---

## Capability 1 — Organization Hierarchy

**Kit module:** [`kit/aws/organization`](../../../../kit/aws/organization)
**Foundation stack:** [`organization/terragrunt.hcl`](organization/terragrunt.hcl)

### What it provisions

```hcl
# From kit/aws/organization/main.tf (simplified)
aws_organizations_organizational_unit "parent"      # "likvid"
  └── aws_organizations_organizational_unit "management"   # "likvid-management"
  │     ├── aws_organizations_account "management"         # Payer/management
  │     ├── aws_organizations_account "networking"         # Hub networking account
  │     ├── aws_organizations_account "automation"         # Terraform state + Identity and Access Management (IAM) user
  │     └── aws_organizations_account "meshstack"          # meshStack replicator
  └── aws_organizations_organizational_unit "landingzones"  # "likvid-landingzones"
        ├── cloud-native/ (managed by cloud-native kit)
        ├── on-prem/      (managed by on-prem kit)
        └── bedrock/      (managed by bedrock kit)
```

Additionally, a separate `m25/` module adds:
```
likvid (root)
  └── likvid-m25-platform   # M25 acquisition — integrated into payer, own platform team
```

### Live state (from `terragrunt output`)

```
Organization ID   : o-0asb1bd1jb
Org root          : r-rpqz
Parent OU (likvid): ou-rpqz-vx54f60i

Management account   : 490004649140
Networking account   : 676206941913
Automation account   : 302263042172
meshStack account    : 484907524426
Management account   : 702461728527  (payer / management)

Landing zones OU   : ou-rpqz-ni6mptmu
  cloud-native OU  : ou-rpqz-zb7gu2r4
    └── dev        : ou-rpqz-qmv63aef
    └── prod       : ou-rpqz-ld2e2ry1
  on-prem OU       : (see on-prem kit)
    └── dev        : ou-rpqz-xj1ziac8
    └── prod       : ou-rpqz-7r4aprt0
  bedrock OU       : ou-rpqz-du12whhh

M25 platform OU    : ou-rpqz-k5htaeoe
```

> **Console:**
> - [Organization root — full OU tree](https://us-east-1.console.aws.amazon.com/organizations/v2/home/root)
> - [likvid parent OU (`ou-rpqz-vx54f60i`)](https://us-east-1.console.aws.amazon.com/organizations/v2/home/organizational-units/ou-rpqz-vx54f60i)
> - [likvid-landingzones OU (`ou-rpqz-ni6mptmu`)](https://us-east-1.console.aws.amazon.com/organizations/v2/home/organizational-units/ou-rpqz-ni6mptmu)
> - [cloud-native OU (`ou-rpqz-zb7gu2r4`)](https://us-east-1.console.aws.amazon.com/organizations/v2/home/organizational-units/ou-rpqz-zb7gu2r4)
> - [M25 platform OU (`ou-rpqz-k5htaeoe`)](https://us-east-1.console.aws.amazon.com/organizations/v2/home/organizational-units/ou-rpqz-k5htaeoe)
> - [All member accounts](https://us-east-1.console.aws.amazon.com/organizations/v2/home/accounts)

### Security guardrail already enforced at this level

The organization module attaches a **Service Control Policy (SCP)** that prevents any account in the
organization from disabling CloudTrail — even with admin permissions:

```json
// kit/aws/organization/main.tf  →  aws_organizations_policy "deny_cloudtrail_deactivation"
{
  "Statement": [{
    "Action": ["cloudtrail:StopLogging", "cloudtrail:DeleteTrail"],
    "Effect": "Deny",
    "Resource": "*"
  }]
}
```

> **Console:** [Service Control Policies list](https://us-east-1.console.aws.amazon.com/organizations/v2/home/policies/service-control-policy)

### Demo commands

```bash
cd foundations/likvid-prod/platforms/aws/organization
AWS_PROFILE=likvid terragrunt output
```

### Talking points
- The OU hierarchy **separates platform/admin workloads from application workloads** — a critical first
  step that the whitepaper identifies as *Resource Hierarchy* maturity.
- The management, networking, automation and meshStack accounts are placed under a dedicated
  `likvid-management` OU, keeping them isolated from application team accounts.
- M25 (acquisition) gets its own OU but is **integrated into the payer account** — cost visibility and
  security posture centralized without disrupting M25's own platform team autonomy.
- The SCP is applied at the org level — no account in any OU can escape CloudTrail logging.

---

## Capability 2 — Centralized Audit Logs

**Kit module:** [`kit/aws/organization-trail`](../../../../kit/aws/organization-trail)
**Foundation stack:** [`organization-trail/terragrunt.hcl`](organization-trail/terragrunt.hcl)

### What it provisions

```
CloudTrail (management account 702461728527)
  name: likvid-prod-trail
  is_organization_trail: true          ← covers ALL accounts in the org
  is_multi_region_trail: false         ← eu-central-1 only (can be changed)
  enable_log_file_validation: true     ← tamper detection via Secure Hash Algorithm 256-bit (SHA-256) digest files
  include_global_service_events: true  ← captures IAM, Security Token Service (STS), etc.
  → writes to →
S3 Bucket (audit account, cross-account write)
  name: likvid-prod-organization-trail-bucket
  versioning: Enabled
  public_access_block: all blocked
  bucket_policy: only CloudTrail service principal can write
```

### Cross-account architecture

The Terragrunt file uses two AWS providers with different roles:

| Provider alias | Account | Role |
|---|---|---|
| `aws.org_mgmt` | `702461728527` (management) | Creates and manages the CloudTrail trail |
| `aws.audit` | `490004649140` (management/audit) | Owns the S3 bucket receiving logs |

This is the **key platform engineering decision**: logs land in a separate account that application
teams and even most platform engineers cannot access — satisfying audit segregation requirements.

### Live state (from `terragrunt output`)

```
Trail ARN  : arn:aws:cloudtrail:eu-central-1:702461728527:trail/likvid-prod-trail
S3 Bucket  : likvid-prod-organization-trail-bucket
```

> **Console:**
> - [CloudTrail trail: likvid-prod-trail](https://eu-central-1.console.aws.amazon.com/cloudtrail/home?region=eu-central-1#/trails/arn:aws:cloudtrail:eu-central-1:702461728527:trail/likvid-prod-trail)
> - [CloudTrail event history](https://eu-central-1.console.aws.amazon.com/cloudtrail/home?region=eu-central-1#/events)
> - [S3 audit bucket: likvid-prod-organization-trail-bucket](https://s3.console.aws.amazon.com/s3/buckets/likvid-prod-organization-trail-bucket?region=eu-central-1)

### Demo commands

```bash
cd foundations/likvid-prod/platforms/aws/organization-trail
AWS_PROFILE=likvid terragrunt output
```

### Talking points
- **One trail, all accounts** — the `is_organization_trail` flag means every new AWS account
  provisioned by meshStack is automatically covered. No per-account setup required.
- **Tamper-proof by design** — the S3 bucket policy only allows `cloudtrail.amazonaws.com` to write.
  The SCP prevents stopping the trail. Log file validation (`enable_log_file_validation`) detects
  if someone modifies a log file after the fact.
- **Terragrunt dependency graph** — `organization-trail` declares a `dependency` on `organization` to
  read the management account ID dynamically. This shows how the stack self-documents its dependencies.
- **Whitepaper alignment:** *Centralized Audit Logs* is classified as a Security & Compliance
  capability. The whitepaper recommends a dedicated audit account as a proven pattern — this setup
  uses the management account for separation, demonstrating the platform choice tradeoff.

---

## Capability 3 — Individual Service Provisioning: AWS Bedrock Landing Zone

**Source module:** [`meshstack-hub/modules/aws/agentic-coding-sandbox/backplane/landingzone`](../../../../../../meshstack-hub/modules/aws/agentic-coding-sandbox/backplane/landingzone) (external, pinned commit `d709611025f677071308e6d0798bfbe6a47a1321`)
**Foundation stack:** [`landingzones/bedrock/terragrunt.hcl`](landingzones/bedrock/terragrunt.hcl)

### What it provisions

The bedrock landing zone creates a dedicated **Organizational Unit** for agentic AI / coding sandbox
workloads, sourced from the `meshstack-hub` module:

```
module source: meshstack-hub//modules/aws/agentic-coding-sandbox/backplane/landingzone
               (github.com/meshcloud/meshstack-hub)

Parent OU: likvid-landingzones (ou-rpqz-ni6mptmu)
Bedrock OU: ou-rpqz-du12whhh
```

### Live state (from `terragrunt output`)

```
organizational_unit_id = "ou-rpqz-du12whhh"
```

> **Console:**
> - [Bedrock OU (`ou-rpqz-du12whhh`)](https://us-east-1.console.aws.amazon.com/organizations/v2/home/organizational-units/ou-rpqz-du12whhh)
> - [AWS Bedrock model access (eu-central-1)](https://eu-central-1.console.aws.amazon.com/bedrock/home?region=eu-central-1#/modelaccess)

### What the meshstack-hub module does

The `agentic-coding-sandbox` module enables AWS Bedrock model access and associated Identity and Access Management (IAM) policies
within accounts placed in this OU. This is a purpose-built **service provisioning** for AI/Machine Learning (ML)
application teams who need:
- Pre-approved Bedrock model access (avoids per-team manual service enablement)
- Guardrails specific to AI workloads (data residency, model usage limits)
- An isolated OU so Bedrock-specific SCPs can be applied without affecting other landing zones

### Demo commands

```bash
cd foundations/likvid-prod/platforms/aws/landingzones/bedrock
AWS_PROFILE=likvid terragrunt output
```

### Talking points
- **Individual Service Provisioning pattern** — the whitepaper describes this as the entry point for
  service ecosystem maturity: start with IaC in a git repo, mature into self-service later.
- **External module pinning** — the `bedrock/terragrunt.hcl` references a commit SHA from
  `meshstack-hub`. This is intentional: platform engineering teams can pin to stable versions and
  upgrade deliberately (like a `package.json` dependency).
- **Use-case tailoring** — instead of allowing every account to enable Bedrock manually, the platform
  team creates a dedicated OU. SCPs can then enforce Bedrock-specific guardrails (e.g., only
  `anthropic.claude-*` models, only `eu-central-1`) without affecting cloud-native workloads.
- **AI/ML as a first-class landing zone type** — this extends the whitepaper's four use cases
  (Cloud-native, Lift&Shift, Container, Data Science) to include **Agentic/GenAI** as a fifth.
  The whitepaper's 2024 edition pre-dates the Bedrock GA era — this is a concrete example of how
  platform engineering teams must continuously extend their portfolio.

---

## Proposed Demo Changes

These changes are **safe to plan** (`terragrunt plan`), take effect within seconds once applied,
and clearly illustrate platform engineering decisions. **Do not apply during the workshop unless
explicitly intended.**

### Change 1 — Add a Region Restriction SCP to the Cloud-Native Prod OU

**File to edit:** [`kit/aws/landingzones/cloud-native/main.tf`](../../../../kit/aws/landingzones/cloud-native/main.tf)

**Why:** Demonstrate that SCPs attached at the OU level provide guardrails without application
team involvement. Adding a `DenyNonEURegion` policy to the `prod` OU (not `dev`) shows the
common pattern of stricter controls in production.

```hcl
# Add to kit/aws/landingzones/cloud-native/main.tf

resource "aws_organizations_policy" "deny_non_eu_regions" {
  name        = "DenyNonEURegions"
  description = "Restrict workloads to EU regions only (data residency)"
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Deny"
      Action    = "*"
      Resource  = "*"
      Condition = {
        StringNotEquals = {
          "aws:RequestedRegion" = ["eu-central-1", "eu-west-1", "eu-west-3"]
        }
      }
    }]
  })
}

resource "aws_organizations_policy_attachment" "deny_non_eu_prod" {
  policy_id = aws_organizations_policy.deny_non_eu_regions.id
  target_id = aws_organizations_organizational_unit.prod.id
}
```

**Platform engineering discussion:**
- `dev` OU remains unrestricted — faster developer iteration
- `prod` OU gets the data residency control — satisfies compliance without blocking dev workflow
- The SCP is defined _in the landing zone kit module_, not hardcoded per-account
- SCPs cannot be overridden even by account admins — this is a hard guardrail

---

### Change 2 — Enable Multi-Region CloudTrail

**File to edit:** [`organization-trail/terragrunt.hcl`](organization-trail/terragrunt.hcl) and [`kit/aws/organization-trail/variables.tf`](../../../../kit/aws/organization-trail/variables.tf)

**Why:** Demonstrate how a single input change in the Terragrunt stack propagates to infrastructure.
Also a genuine security improvement (global services like IAM are always logged, but Elastic Compute Cloud (EC2) in
non-eu regions would currently be missed).

```hcl
# In foundations/likvid-prod/platforms/aws/organization-trail/terragrunt.hcl
# Change:
inputs = {
  trail_name     = "likvid-prod-trail"
  s3_bucket_name = "likvid-prod-organization-trail-bucket"
  # ADD:
  is_multi_region_trail = true
}
```

And update `kit/aws/organization-trail/variables.tf`:
```hcl
variable "is_multi_region_trail" {
  type    = bool
  default = false
  description = "Capture events from all regions (recommended for production)"
}
```

And `kit/aws/organization-trail/main.tf`:
```hcl
resource "aws_cloudtrail" "organization" {
  # ...
  is_multi_region_trail = var.is_multi_region_trail   # was hardcoded false
}
```

**Platform engineering discussion:**
- This change costs ~$2/month extra (100K events) — demonstrates cost awareness
- The kit module exposes the variable, the foundation stack sets the value — clear separation of concerns
- A PR with this change would show up in git history: auditability of infrastructure decisions

---

### Change 3 — Add a `sandbox` Landing Zone for Self-Service Experimentation

**Why:** Show how the modular kit pattern makes adding new landing zones straightforward — and
demonstrate the platform engineering principle of providing a "safe to fail" environment.

**New file:** `foundations/likvid-prod/platforms/aws/landingzones/sandbox/terragrunt.hcl`

```hcl
include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "organization" {
  config_path = "../../organization"
}

terraform {
  source = "${get_repo_root()}//kit/aws/landingzones/cloud-native"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region              = "eu-central-1"
  allowed_account_ids = ["${include.platform.locals.platform.aws.accountId}"]
}
EOF
}

inputs = {
  parent_ou_id = dependency.organization.outputs.landingzones_ou_id
}
```

Then add a separate SCP for sandboxes (e.g., monthly spend cap via Service Quotas, or an explicit
`AllowListServices` approach restricting to only inexpensive services).

**Platform engineering discussion:**
- Reuses the existing `cloud-native` kit module — Don't Repeat Yourself (DRY) principle
- Sandbox OU gets different (more permissive) SCPs than `prod` — tailored landing zones
- This is a 10-minute change — the heavy lifting is already done in `kit/`
- meshStack can expose a "Request Sandbox" self-service tile that provisions into this OU

---

### Change 4 — Add a Tagging Policy to Enforce Cost Attribution

**File to edit:** [`kit/aws/organization/main.tf`](../../../../kit/aws/organization/main.tf)

**Why:** Show another type of AWS Organizations policy (Tag Policies, not SCPs) and connect to
the *Cost Management* governance function.

```hcl
# Add to kit/aws/organization/main.tf

resource "aws_organizations_policy" "require_cost_tags" {
  name    = "RequireCostCenterTag"
  type    = "TAG_POLICY"
  content = jsonencode({
    tags = {
      CostCenter = {
        tag_key = {
          "@@assign" = "CostCenter"
        }
        enforced_for = {
          "@@assign" = ["ec2:instance", "rds:db", "s3:bucket"]
        }
      }
    }
  })
}

resource "aws_organizations_policy_attachment" "require_cost_tags" {
  policy_id = aws_organizations_policy.require_cost_tags.id
  target_id = aws_organizations_organizational_unit.landingzones.id
}
```

**Platform engineering discussion:**
- Tag policies are *reporting policies* (non-blocking) vs SCPs which are *hard deny*
- `CostCenter` tag enables cost allocation in AWS Cost Explorer — links cloud spend to business units
- Applied at `likvid-landingzones` OU: all application accounts inherit it automatically
- This is the infrastructure-as-code expression of a *Cloud Tenant Database* — the whitepaper
  identifies this as a foundational capability that scales better than spreadsheets

---

## Architecture at a Glance

```
AWS Organizations (o-0asb1bd1jb)
└── Root (r-rpqz)
    └── likvid (ou-rpqz-vx54f60i)  ← parent_ou_name = "likvid"
        ├── likvid-management (OU)
        │   ├── account: 702461728527  [management/payer]
        │   ├── account: 676206941913  [networking]  → Transit Gateway
        │   ├── account: 302263042172  [automation]  → TF state S3 bucket
        │   └── account: 484907524426  [meshstack]  → meshStack replicator
        ├── likvid-landingzones (ou-rpqz-ni6mptmu)
        │   ├── cloud-native (ou-rpqz-zb7gu2r4)
        │   │   ├── dev  (ou-rpqz-qmv63aef)  — application team accounts
        │   │   └── prod (ou-rpqz-ld2e2ry1)  — application team accounts
        │   ├── on-prem
        │   │   ├── dev  (ou-rpqz-xj1ziac8)  — hybrid connectivity accounts
        │   │   └── prod (ou-rpqz-7r4aprt0)  — hybrid connectivity accounts
        │   └── bedrock (ou-rpqz-du12whhh)   — GenAI/agentic coding accounts
        └── likvid-m25-platform (ou-rpqz-k5htaeoe)  ← M25 acquisition

CloudTrail: arn:aws:cloudtrail:eu-central-1:702461728527:trail/likvid-prod-trail
  → S3: likvid-prod-organization-trail-bucket (cross-account, audit-isolated)

SCPs applied:
  [org-root] DenyDisableCloudTrail  ← no account can stop logging
  [propose]  DenyNonEURegions       ← cloud-native/prod data residency
  [propose]  RequireCostCenterTag   ← cost attribution on all LZ accounts
```

---

## Whitepaper Notes & Update Suggestions

The [Landing Zone Ultimate Guide](./Whitepaper%20LZ%20Ultimate%20Guide.md) is a solid foundation
but reflects a ~2022 perspective. The following points deserve an update for a modern platform
engineering audience:

| Whitepaper Framing | Modern Platform Engineering Update |
|---|---|
| Landing zones as IT Service Management (ITSM) deliverables | Landing zones as **continuously evolved platform products** with a team owning them long-term |
| Four use case archetypes (cloud-native, lift&shift, container, data science) | Add a fifth: **Agentic/GenAI** (Bedrock, Vertex AI, Azure OpenAI) — requires distinct service allowlists and model governance |
| Infrastructure as Code (IaC) in a git repo as "individual service provisioning" | This is the **baseline**, not the ceiling — the LCF `kit/` pattern shows how to evolve individual IaC into a reusable module catalog |
| Focus on Terraform/ClickOps spectrum | The Internal Developer Platform (IDP)/platform product layer (e.g., meshStack) adds a **self-service** layer *on top of* IaC — developers don't touch Terragrunt; they click "Request environment" |
| Landing zone design = one-time architecture work | Platform engineering = **continuous delivery of platform changes** via Pull Requests (PRs), GitOps pipelines and automated `terragrunt plan` in Continuous Integration (CI) |
| CloudTrail as optional security enhancement | CloudTrail (+ SCPs preventing its removal) is table stakes — the SCP pattern shown in `kit/aws/organization` enforces this non-negotiably |

---

## Glossary

| Acronym | Full Name | Context in this Demo |
|---|---|---|
| **ARN** | Amazon Resource Name | Globally unique identifier for any AWS resource. Used throughout to reference the CloudTrail trail (`arn:aws:cloudtrail:…`) and Organizations OUs (`arn:aws:organizations:…`). |
| **AWS** | Amazon Web Services | The public cloud platform used by Likvid Bank. The LCF AWS stack manages the organisation, audit logging and landing zones on this platform. |
| **CI** | Continuous Integration | Automated pipeline (GitHub Actions) that runs `terragrunt plan` on every pull request. The `common.hcl` detects `CI=true` and switches to read-only (`validation`) IAM roles. |
| **CLI** | Command-Line Interface | The `aws` CLI and `terragrunt` CLI are the primary tools for interacting with the platform during the demo. |
| **DRY** | Don't Repeat Yourself | Software engineering principle. The `kit/` + `foundations/` split enforces DRY: module logic lives once in `kit/`, environment-specific values live in `foundations/`. |
| **EC2** | Elastic Compute Cloud | AWS virtual machine service. Referenced in the tagging policy proposal as a resource type that must carry a `CostCenter` tag. |
| **EU** | European Union | Geographical/regulatory scope. The region restriction SCP limits workloads to EU AWS regions (`eu-central-1`, `eu-west-1`, `eu-west-3`) for data residency compliance. |
| **GA** | General Availability | Indicates a cloud service is production-ready. Referenced to note that AWS Bedrock reached GA after the whitepaper was written. |
| **GCP** | Google Cloud Platform | Google's public cloud. The LCF `kit/` pattern is reused for GCP alongside AWS and Azure, demonstrating cloud-agnostic platform engineering. |
| **GenAI** | Generative Artificial Intelligence | AI systems that generate content (text, code, images). The Bedrock landing zone was created specifically for GenAI/agentic workloads. |
| **IaC** | Infrastructure as Code | Managing cloud infrastructure via declarative code files (Terraform/OpenTofu `.tf` files) rather than manual console clicks. All LCF modules are IaC. |
| **IAM** | Identity and Access Management | AWS service for controlling who can do what. In this demo: SSO permission sets assigned to admin users, `DenyCreateIAMUser` SCP, and cross-account assume-role policies. |
| **ID** | Identifier | A unique string assigned by AWS to resources (e.g., OU ID `ou-rpqz-ni6mptmu`, account ID `702461728527`). Captured as Terragrunt outputs and passed between dependent modules. |
| **IDP** | Internal Developer Platform | A self-service platform product built by platform teams for application developers. meshStack functions as the IDP layer on top of the Terraform IaC in this demo. |
| **IONOS** | IONOS Cloud | European cloud provider. The LCF `kit/` structure also covers IONOS, demonstrating the multi-cloud nature of the platform. |
| **ITSM** | IT Service Management | Traditional ticket-based IT operations model. The whitepaper warns against treating landing zone provisioning as ITSM (manual approvals, long lead times) — IaC + self-service replaces it. |
| **LCF** | Likvid Cloud Foundation | The internal platform team and their code repository (`likvid-cloudfoundation`) that manages all cloud platforms for Likvid Bank. |
| **LZ** | Landing Zone | A pre-configured cloud environment (AWS account + OU + SCPs + guardrails) tailored for a specific application team use case. See also: cloud-native, on-prem, bedrock landing zones. |
| **M25** | M25 Bank | A "digital native" bank acquired by Likvid Bank in 2024. Its AWS accounts are integrated into the Likvid payer account under the `likvid-m25-platform` OU for cost and security visibility. |
| **ML** | Machine Learning | A category of AI. Referenced alongside Bedrock as a workload type that the bedrock landing zone serves. |
| **OU** | Organizational Unit | A folder-like container within AWS Organizations. OUs group accounts and are the attachment point for SCPs. In this demo: `likvid-landingzones`, `cloud-native`, `bedrock`, etc. |
| **OVH** | OVH Cloud | French cloud provider. Another cloud in the LCF multi-cloud `kit/` structure. |
| **PR** | Pull Request | A code review mechanism in git. Platform changes (adding an SCP, enabling multi-region CloudTrail) are proposed as PRs — providing audit history and peer review for infrastructure decisions. |
| **RDS** | Relational Database Service | AWS managed database service. Referenced in the tagging policy proposal as a resource type requiring a `CostCenter` tag. |
| **S3** | Simple Storage Service | AWS object storage. Used in this demo as: (1) the remote Terraform state backend (`likvid-tf-state` bucket) and (2) the CloudTrail log archive (`likvid-prod-organization-trail-bucket`). |
| **SCP** | Service Control Policy | An AWS Organizations policy type that sets maximum permissions for accounts in an OU — a hard guardrail that cannot be overridden by account admins. Used to deny disabling CloudTrail and (proposed) to restrict non-EU regions. |
| **SHA / SHA-256** | Secure Hash Algorithm (256-bit) | Cryptographic hash function. CloudTrail's `enable_log_file_validation` generates SHA-256 digest files so any tampering with log files after the fact can be detected. |
| **SSO** | Single Sign-On | AWS Identity Center (formerly AWS SSO) allows users to log into multiple AWS accounts with one identity. Used here to assign the `AWSAdministratorAccess` permission set to foundation admin users across all management accounts. |
| **STS** | Security Token Service | AWS service that issues temporary credentials via `AssumeRole`. Used by Terragrunt providers to assume cross-account roles (e.g., `OrganizationAccountAccessRole`) when deploying kit modules. |
| **TF** | Terraform / OpenTofu | The IaC tool used to define and deploy AWS resources. This demo uses OpenTofu (the open-source fork) v1.11.x, invoked via Terragrunt as the orchestration layer. |
| **TGW** | Transit Gateway | AWS networking service. The `networking/` module deploys a Transit Gateway (`likvid-tgw`) in the dedicated networking account for on-premises hybrid connectivity. |
| **VPC** | Virtual Private Cloud | AWS private network. Accounts in the `on-prem` landing zone OU are configured to connect their VPCs to the Transit Gateway for hybrid connectivity. |

---

*Generated from live state read on 2026-03-16. Re-run `terragrunt output` to refresh values before the demo.*
