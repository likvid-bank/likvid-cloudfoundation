---
name: hub
description: >
  How this foundation works with meshstack-hub modules — consuming them as deployed building blocks
  and running foundation e2e smoke tests against them. Use when wiring a hub building block into a
  foundation, or adding/running/debugging a foundation e2e test. The e2e invocation protocol is
  owned by the hub's e2e-test skill; this skill points you there and covers the foundation side.
---

# Working with meshstack-hub modules

[meshstack-hub](https://github.com/meshcloud/meshstack-hub) is the canonical Terraform module
registry for meshStack. This foundation **consumes** hub modules in two ways:

1. **As deployed building blocks** — a foundation unit (`foundations/likvid-prod/.../buildingblocks/<svc>/`)
   sources the hub module via a pinned Git ref and registers a `meshstack_building_block_definition`.
2. **As e2e smoke tests** — an `e2e/` unit next to the deployment sources the hub's `e2e/` module and
   orders an ephemeral building block to verify the deployed BBD actually works.

Keep a sibling checkout at `../meshstack-hub`.

## The e2e invocation protocol is owned by the hub

The contract for how a hub `e2e/` module is invoked — the variables it exposes and its two
mutually-exclusive modes — is defined once, in the hub repo, and is the **single source of truth**:

> **[meshstack-hub `e2e-test` skill](../../../meshstack-hub/.agents/skills/e2e-test/SKILL.md)**
> (GitHub: <https://github.com/meshcloud/meshstack-hub/blob/main/.agents/skills/e2e-test/SKILL.md>)

Read it before wiring or changing an `e2e/terragrunt.hcl`. Do not re-document the protocol here.

## This foundation's side of the protocol: foundation mode

Foundation e2e units run in **foundation mode** — `test_context.bbd_version_ref` is set: the
deployment unit (`../`) already created the BBD, and the e2e unit only **orders** an ephemeral
building block against it.

The `e2e/terragrunt.hcl` therefore:

- Sources the hub `e2e/` module at the deployed `hub.git_ref`.
- Generates `smoke.auto.tfvars.json` setting `test_context` with `workspace`, `name_suffix`,
  `hub_git_ref`, and `bbd_version_ref` — read from the deployment's `e2e` output via a `dependency`.
  `tofu test` cannot type-decode complex `TF_VAR_*`, hence the `.auto.tfvars.json`.
- Omits build-from-source provider secrets (the ephemeral backplane is not built in foundation mode).
  For a **workspace-level** block (e.g. storage-bucket) `fixtures` is also omitted; for a
  **tenant-level** block, still pass `fixtures.<cloud>.mesh_tenant_id` — the e2e module needs it for
  the `target_ref` even though `bbd_version_ref` is set.

```hcl
generate "smoke_tfvars" {
  path      = "smoke.auto.tfvars.json"
  if_exists = "overwrite"
  contents = jsonencode({
    test_context = {
      workspace       = dependency.deployment.outputs.e2e.owning_workspace
      name_suffix     = run_cmd("--terragrunt-quiet", "date", "-u", "+%Y%m%d%H%M%S")
      hub_git_ref     = dependency.deployment.outputs.e2e.hub.git_ref
      bbd_version_ref = dependency.deployment.outputs.e2e.building_block_definition.version_ref
    }
  })
}
```

Run a foundation e2e unit (see also the `run-lcf-modules` skill for credential setup):

```bash
cd foundations/likvid-prod/platforms/stackit/buildingblocks/<svc>/e2e
terragrunt test
```
