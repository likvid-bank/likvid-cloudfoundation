# Part 3 — Individual Service Provisioning: AWS Bedrock Landing Zone

**Source module:** [`meshstack-hub/.../landingzone`](https://github.com/meshcloud/meshstack-hub/tree/d709611025f677071308e6d0798bfbe6a47a1321/modules/aws/agentic-coding-sandbox/backplane/landingzone) (external, pinned commit)
**Foundation stack:** [`landingzones/bedrock/terragrunt.hcl`](../landingzones/bedrock/terragrunt.hcl)

## What it provisions

The bedrock landing zone creates a dedicated **Organizational Unit** for agentic AI / coding sandbox
workloads, sourced from the [`meshstack-hub`](https://github.com/meshcloud/meshstack-hub) module:

```
module source: [meshstack-hub//modules/aws/agentic-coding-sandbox/backplane/landingzone](https://github.com/meshcloud/meshstack-hub/tree/d709611025f677071308e6d0798bfbe6a47a1321/modules/aws/agentic-coding-sandbox/backplane/landingzone)
               (github.com/meshcloud/meshstack-hub)

Parent OU: likvid-landingzones (ou-rpqz-ni6mptmu)
Bedrock OU: ou-rpqz-du12whhh
```

## Live state

```
organizational_unit_id = "ou-rpqz-du12whhh"
```

> **Console:**
> - [Bedrock OU (`ou-rpqz-du12whhh`)](https://us-east-1.console.aws.amazon.com/organizations/v2/home/organizational-units/ou-rpqz-du12whhh)
> - [AWS Bedrock model access (eu-central-1)](https://eu-central-1.console.aws.amazon.com/bedrock/home?region=eu-central-1#/modelaccess)

## What the meshstack-hub module does

The `agentic-coding-sandbox` module enables AWS Bedrock model access and associated IAM policies
within accounts placed in this OU. This is a purpose-built **service provisioning** for AI/ML
application teams who need:

- Pre-approved Bedrock model access (avoids per-team manual service enablement)
- Guardrails specific to AI workloads (data residency, model usage limits)
- An isolated OU so Bedrock-specific SCPs can be applied without affecting other landing zones

## Talking points

- **Individual Service Provisioning pattern** — the Ultimate Landing Zone Guide describes this as the entry point for
  service ecosystem maturity: start with IaC in a git repo, mature into self-service later.
- **External module pinning** — the `bedrock/terragrunt.hcl` references a commit SHA from
  `meshstack-hub`. This is intentional: platform engineering teams can pin to stable versions and
  upgrade deliberately (like a `package.json` dependency).
- **Use-case tailoring** — instead of allowing every account to enable Bedrock manually, the platform
  team creates a dedicated OU. SCPs can then enforce Bedrock-specific guardrails (e.g., only
  `anthropic.claude-*` models, only `eu-central-1`) without affecting cloud-native workloads.
- **AI/ML as a first-class landing zone type** — this extends the Ultimate Landing Zone Guide's four use cases
  (Cloud-native, Lift&Shift, Container, Data Science) to include **Agentic/GenAI** as a fifth.
  The Ultimate Landing Zone Guide's 2024 edition pre-dates the Bedrock GA era — this is a concrete example of how
  platform engineering teams must continuously extend their portfolio.
