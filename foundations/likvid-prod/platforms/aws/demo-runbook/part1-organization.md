# Part 1 — Organization Hierarchy

**Kit module:** [`kit/aws/organization`](../../../../../kit/aws/organization)
**Foundation stack:** [`organization/terragrunt.hcl`](../organization/terragrunt.hcl)

## What it provisions

```
aws_organizations_organizational_unit "parent"      # "likvid"
  └── aws_organizations_organizational_unit "management"   # "likvid-management"
  │     ├── aws_organizations_account "management"         # Payer/management
  │     ├── aws_organizations_account "networking"         # Hub networking account
  │     ├── aws_organizations_account "automation"         # Terraform state + IAM user
  │     └── aws_organizations_account "meshstack"          # meshStack replicator
  └── aws_organizations_organizational_unit "landingzones"  # "likvid-landingzones"
        ├── cloud-native/ (managed by cloud-native kit)
        ├── on-prem/      (managed by on-prem kit)
        └── bedrock/      (managed by bedrock kit)
```

Additionally, a separate [`m25/`](../m25/terragrunt.hcl) module adds:
```
likvid (root)
  └── likvid-m25-platform   # M25 acquisition — integrated into payer, own platform team
```

## Live state

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
> - [likvid parent OU (`ou-rpqz-vx54f60i`)](https://us-east-1.console.aws.amazon.com/organizations/v2/home/organizational-units/ou-rpqz-vx54f60i) (UI Bug: Switch Tabs to show Children)
> - [likvid-landingzones OU (`ou-rpqz-ni6mptmu`)](https://us-east-1.console.aws.amazon.com/organizations/v2/home/organizational-units/ou-rpqz-ni6mptmu)

## Security guardrail already enforced at this level

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

## Talking points

- The OU hierarchy **separates platform/admin workloads from application workloads** — a critical first
  step that the whitepaper identifies as *Resource Hierarchy* maturity.
- The management, networking, automation and meshStack accounts are placed under a dedicated
  `likvid-management` OU, keeping them isolated from application team accounts.
- M25 (acquisition) gets its own OU but is **integrated into the payer account** — cost visibility and
  security posture centralized without disrupting M25's own platform team autonomy.
- The SCP is applied at the org level — no account in any OU can escape CloudTrail logging.
