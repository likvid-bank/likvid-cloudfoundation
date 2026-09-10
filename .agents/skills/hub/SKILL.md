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

Foundation e2e units run in **foundation mode** — `test_context.mode = "foundation"`. The deployment
unit (`../`) has already published the BBD, and the e2e unit only **orders** an ephemeral building
block against it.

**One credential, the meshStack API key.** That is the invariant to protect. The hub module finds
the published definition through the meshStack API itself, so an `e2e/` unit needs no cloud
credential, no state backend and no `dependency` on the deployment. If a smoke test starts wanting
one, the hub mode module is taking a value it should be looking up — fix it there, do not add a
secret to `.github/workflows/smoke-test.yml`.

The `e2e/terragrunt.hcl` therefore:

- Includes `foundations/<foundation>/smoke.hcl`, which renders the meshStack provider and names the
  platform workspace. Including it is also what puts the unit into the smoke-test workflow.
- Sources the hub `e2e/` module at the deployed `hub.git_ref` (via `../hub.hcl`, shared with the
  deployment).
- Generates `smoke.auto.tfvars.json` — `tofu test` cannot type-decode complex `TF_VAR_*` — setting
  `test_context` to static values only: `mode`, `workspace`, `bbd_draft`, plus the per-run
  `name_suffix` and `run_id` it reads from `foundations/<foundation>/smoke_run.hcl`. That file is
  where both e2e units get them, so the shape is defined once; `run_cmd` is cached per unit, so a
  `run --all` gives each test case its own `run_id`, as hub mode does.
- Omits the backplane secrets and `hub_git_ref` — foundation mode never installs `modes/hub`.
- Omits `fixtures` for a **workspace-level** block (e.g. storage-bucket). A **tenant-level** block
  still needs `fixtures.<cloud>.mesh_tenant_id` for its `target_ref`.

`bbd_draft` must match the flag the deployment published the definition with: with `bbd_draft = true`
the test orders against `version_latest`, otherwise against `version_latest_release`. Sharing
`../hub.hcl` keeps the two in step.

```hcl
include "smoke" {
  path   = find_in_parent_folders("smoke.hcl")
  expose = true
}

include "smoke_run" {
  path   = find_in_parent_folders("smoke_run.hcl")
  expose = true
}

generate "smoke_tfvars" {
  path              = "smoke.auto.tfvars.json"
  if_exists         = "overwrite"
  disable_signature = true
  contents = jsonencode({
    test_context = {
      mode        = "foundation"
      workspace   = include.smoke.locals.meshstack.workspace
      bbd_draft   = include.hub.locals.bbd_draft
      name_suffix = include.smoke_run.locals.name_suffix
      run_id      = include.smoke_run.locals.run_id
    }
  })
}
```

A hub module still on the older `count` gate reads the mode off `bbd_version_ref` instead and
evaluates `hub_git_ref` even in foundation mode. `platforms/stackit/buildingblocks/storage-buckets/e2e`
is one such unit: it keeps its `dependency "deployment"` and rides `platforms test` in `build.yml`
until the hub module moves to the `modes/` layout.

## Running a foundation e2e test

Smoke tests run in GitHub Actions. Dispatch `smoke-test.yml`, optionally narrowing to one case with
a path prefix under the foundation:

```bash
gh workflow run smoke-test.yml -f prefix=platforms/ske/starterkit/e2e
gh run watch
```

Locally is possible too, since the only credential is the meshStack API key (see the
`run-lcf-modules` skill for credential setup):

```bash
cd foundations/likvid-prod/platforms/ske/starterkit/e2e
terragrunt test
```
