# AWS Landing Zone Workshop — Demo Runbook

> **Scope:** This runbook guides a live demo of the Likvid Bank Cloud Foundation (LCF) Amazon Web Services (AWS) platform.
> It covers three landing zone capabilities deployed via the `foundations/likvid-prod/platforms/aws`
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
| [`part1-organization.md`](part1-organization.md) | Organization Hierarchy | `organization`, `landingzones/*`, `m25` |
| [`part2-audit-logs.md`](part2-audit-logs.md) | Centralized Audit Logs | `organization-trail` |
| [`part3-bedrock.md`](part3-bedrock.md) | Bedrock Landing Zone | `landingzones/bedrock` |

```bash
cd foundations/likvid-prod/platforms/aws/demo-runbook
terragrunt apply
```

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
    ├── landingzones/
    │   └── bedrock/         # [Demo 3] → meshstack-hub agentic-coding-sandbox
    └── demo-runbook/        # This module — renders demo part Markdown files
```

**Key design principle:** `kit/` defines *what* to build; `foundations/` defines *where* with
environment-specific inputs. Changes flow as Pull Requests (PRs) through `kit/` and are consumed by one or more
`foundations/` stacks — the same pattern used across AWS, Azure, Google Cloud Platform (GCP) and other clouds in this repo.

---

## Architecture at a Glance

```
AWS Organizations
└── Root
    └── likvid  ← parent_ou_name = "likvid"
        ├── likvid-management (OU)
        │   ├── account: management  [management/payer]
        │   ├── account: networking  → Transit Gateway
        │   ├── account: automation  → TF state S3 bucket
        │   └── account: meshstack  → meshStack replicator
        ├── likvid-landingzones
        │   ├── cloud-native
        │   │   ├── dev   — application team accounts
        │   │   └── prod  — application team accounts
        │   ├── on-prem
        │   │   ├── dev   — hybrid connectivity accounts
        │   │   └── prod  — hybrid connectivity accounts
        │   └── bedrock   — GenAI/agentic coding accounts
        └── likvid-m25-platform  ← M25 acquisition

CloudTrail: org-wide trail → S3 audit bucket (cross-account, audit-isolated)

SCPs applied:
  [org-root] DenyDisableCloudTrail  ← no account can stop logging
  [propose]  DenyNonEURegions       ← cloud-native/prod data residency
  [propose]  RequireCostCenterTag   ← cost attribution on all LZ accounts
```

---

## Ultimate Landing Zone Guide Notes & Update Suggestions

The [Landing Zone Ultimate Guide](../Whitepaper%20LZ%20Ultimate%20Guide.md) is a solid foundation
but reflects a ~2022 perspective. The following points deserve an update for a modern platform
engineering audience:

| Guide Framing | Modern Platform Engineering Update |
|---|---|
| Landing zones as ITSM deliverables | Landing zones as **continuously evolved platform products** with a team owning them long-term |
| Four use case archetypes (cloud-native, lift&shift, container, data science) | Add a fifth: **Agentic/GenAI** (Bedrock, Vertex AI, Azure OpenAI) — requires distinct service allowlists and model governance |
| IaC in a git repo as "individual service provisioning" | This is the **baseline**, not the ceiling — the LCF `kit/` pattern shows how to evolve individual IaC into a reusable module catalog |
| Focus on Terraform/ClickOps spectrum | The IDP/platform product layer (e.g., meshStack) adds a **self-service** layer *on top of* IaC — developers don't touch Terragrunt; they click "Request environment" |
| Landing zone design = one-time architecture work | Platform engineering = **continuous delivery of platform changes** via PRs, GitOps pipelines and automated `terragrunt plan` in CI |
| CloudTrail as optional security enhancement | CloudTrail (+ SCPs preventing its removal) is table stakes — the SCP pattern shown in `kit/aws/organization` enforces this non-negotiably |

---

## Glossary

| Acronym | Full Name | Context in this Demo |
|---|---|---|
| **ARN** | Amazon Resource Name | Globally unique identifier for any AWS resource. |
| **AWS** | Amazon Web Services | The public cloud platform used by Likvid Bank. |
| **CI** | Continuous Integration | Automated pipeline (GitHub Actions) that runs `terragrunt plan` on every pull request. |
| **CLI** | Command-Line Interface | The `aws` CLI and `terragrunt` CLI are the primary tools for interacting with the platform during the demo. |
| **DRY** | Don't Repeat Yourself | The `kit/` + `foundations/` split enforces DRY: module logic lives once in `kit/`, environment-specific values live in `foundations/`. |
| **EC2** | Elastic Compute Cloud | AWS virtual machine service. Referenced in the tagging policy proposal. |
| **EU** | European Union | Geographical/regulatory scope for region restriction SCP. |
| **GA** | General Availability | Indicates a cloud service is production-ready. |
| **GCP** | Google Cloud Platform | Google's public cloud. The LCF `kit/` pattern is reused for GCP alongside AWS and Azure. |
| **GenAI** | Generative Artificial Intelligence | AI systems that generate content. The Bedrock landing zone was created specifically for GenAI/agentic workloads. |
| **IaC** | Infrastructure as Code | Managing cloud infrastructure via declarative code files rather than manual console clicks. |
| **IAM** | Identity and Access Management | AWS service for controlling who can do what. |
| **IDP** | Internal Developer Platform | A self-service platform product built by platform teams for application developers. |
| **ITSM** | IT Service Management | Traditional ticket-based IT operations model. |
| **LCF** | Likvid Cloud Foundation | The internal platform team and their code repository. |
| **LZ** | Landing Zone | A pre-configured cloud environment tailored for a specific application team use case. |
| **M25** | M25 Bank | A digital native bank acquired by Likvid Bank in 2024. |
| **ML** | Machine Learning | A category of AI referenced alongside Bedrock workloads. |
| **OU** | Organizational Unit | A folder-like container within AWS Organizations. |
| **PR** | Pull Request | A code review mechanism in git for infrastructure changes. |
| **RDS** | Relational Database Service | AWS managed database service. Referenced in the tagging policy proposal. |
| **S3** | Simple Storage Service | AWS object storage used for Terraform state and CloudTrail log archive. |
| **SCP** | Service Control Policy | An AWS Organizations policy type that sets maximum permissions for accounts in an OU. |
| **SHA-256** | Secure Hash Algorithm (256-bit) | Cryptographic hash function used by CloudTrail log file validation. |
| **SSO** | Single Sign-On | AWS Identity Center allows users to log into multiple AWS accounts with one identity. |
| **STS** | Security Token Service | AWS service that issues temporary credentials via `AssumeRole`. |
| **TF** | Terraform / OpenTofu | The IaC tool used to define and deploy AWS resources. |
| **TGW** | Transit Gateway | AWS networking service for on-premises hybrid connectivity. |
| **VPC** | Virtual Private Cloud | AWS private network for hybrid connectivity accounts. |
