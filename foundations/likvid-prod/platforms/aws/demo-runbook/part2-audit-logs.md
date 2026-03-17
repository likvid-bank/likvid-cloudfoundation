# Part 2 — Centralized Audit Logs

**Kit module:** [`kit/aws/organization-trail`](../../../../../kit/aws/organization-trail)
**Foundation stack:** [`organization-trail/terragrunt.hcl`](../organization-trail/terragrunt.hcl)

## What it provisions

```
CloudTrail (management account 702461728527)
  name: likvid-prod-trail
  is_organization_trail: true          ← covers ALL accounts in the org
  is_multi_region_trail: false         ← eu-central-1 only (can be changed)
  enable_log_file_validation: true     ← tamper detection via SHA-256 digest files
  include_global_service_events: true  ← captures IAM, STS, etc.

  ➡️ writes to ➡️

S3 Bucket (audit account, cross-account write)
  name: likvid-prod-organization-trail-bucket
  versioning: Enabled
  public_access_block: all blocked
  bucket_policy: only CloudTrail service principal can write
```

## Cross-account architecture

The Terragrunt file uses two AWS providers with different roles:

| Provider alias | Account | Role |
|---|---|---|
| `aws.org_mgmt` | `702461728527` (management) | Creates and manages the CloudTrail trail |
| `aws.audit` | `490004649140` (management/audit) | Owns the S3 bucket receiving logs |

This is the **key platform engineering decision**: logs land in a separate account that application
teams and even most platform engineers cannot access — satisfying audit segregation requirements.

[`kit/aws/organization-trail/main.tf`](../../../../../kit/aws/organization-trail/main.tf):

```hcl
resource "aws_s3_bucket" "cloudtrail" {
  provider = aws.audit
  bucket   = var.s3_bucket_name
}
```

```hcl
resource "aws_cloudtrail" "organization" {
  provider                      = aws.org_mgmt
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail.bucket
  is_organization_trail         = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true
  include_global_service_events = true

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}
```

## Live state

```
Trail ARN  : arn:aws:cloudtrail:eu-central-1:702461728527:trail/likvid-prod-trail
S3 Bucket  : likvid-prod-organization-trail-bucket
```

> **Console:**
> - [S3 audit bucket: likvid-prod-organization-trail-bucket](https://s3.console.aws.amazon.com/s3/buckets/likvid-prod-organization-trail-bucket?region=eu-central-1)

## Talking points
- **Why "Access Denied"** with current login? See above! Switch to Browser session with account `490004649140`.
- **One trail, all accounts** — the `is_organization_trail` flag means every new AWS account
  provisioned by meshStack is automatically covered. No per-account setup required.
- **Tamper-proof by design** — the S3 bucket policy only allows `cloudtrail.amazonaws.com` to write.
  The SCP prevents stopping the trail. Log file validation (`enable_log_file_validation`) detects
  if someone modifies a log file after the fact.
- **Terragrunt dependency graph** — `organization-trail` declares a `dependency` on `organization` to
  read the management account ID dynamically. This shows how the stack self-documents its dependencies.
- **Guide alignment:** *Centralized Audit Logs* is classified as a Security & Compliance
  capability. The Ultimate Landing Zone Guide recommends a dedicated audit account as a proven pattern — this setup
  uses the management account for separation, demonstrating the platform choice tradeoff.

## Proposed demo change — Enable Multi-Region CloudTrail

**Why not enabled yet?** From git history: `is_multi_region_trail = false` was introduced in the
initial `organization-trail` commit (`ca44cb23`, 2025-09-29), with no explicit rationale recorded.
Most likely drivers were keeping scope/cost low while focusing on EU-central usage.

**Why:** Demonstrate how a single input change in the Terragrunt stack propagates to infrastructure.
Also a genuine security improvement (global services like IAM are always logged, but EC2 in
non-eu regions would currently be missed).

### Step 1 (kit): make CloudTrail multi-region configurable

Edit [`kit/aws/organization-trail/variables.tf`](../../../../../kit/aws/organization-trail/variables.tf):

```hcl
variable "is_multi_region_trail" {
  type        = bool
  default     = false
  description = "Whether the organization trail should capture events in all AWS regions."
}
```

Edit [`kit/aws/organization-trail/main.tf`](../../../../../kit/aws/organization-trail/main.tf):

```hcl
resource "aws_cloudtrail" "organization" {
  # ...
  is_multi_region_trail = var.is_multi_region_trail
}
```

### Step 2 (foundation): enable it in this environment

Edit [`organization-trail/terragrunt.hcl`](../organization-trail/terragrunt.hcl):

```hcl
# In foundations/likvid-prod/platforms/aws/organization-trail/terragrunt.hcl
inputs = {
  trail_name     = "likvid-prod-trail"
  s3_bucket_name = "likvid-prod-organization-trail-bucket"
  auditors       = include.platform.locals.foundation_pam.audit_log_auditors
  # CHANGE:
  is_multi_region_trail = true
}
```
