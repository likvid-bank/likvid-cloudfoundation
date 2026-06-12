---
name: foundation-module
description: Run, plan, apply, and upgrade LCF (likvid-cloudfoundation) Terragrunt modules. Use when asked to run terragrunt plan/apply, upgrade a hub module, run e2e smoke tests, or fix provider/credential errors in foundations/.
---

# Running LCF Modules

LCF is a Terragrunt monorepo. Modules live under `foundations/likvid-prod/`. Each module directory has a `terragrunt.hcl`. All operations follow the pattern: source credentials → `cd` to module → run `terragrunt plan|apply`.

**Tools are provided by the nix devShell** (`nix develop` or the pre-activated env).

---

## Prerequisites

The nix devShell must be active or the nix profile available. Confirm:

```bash
which terragrunt  # should resolve to a nix store path
```

---

## Credential Setup (do this first, every session)

`setup-env.sh` loads secrets from Vault (via kubectl port-forward). **It must be sourced in zsh** — it uses `$ZSH_VERSION` and fails silently in bash.

Claude Code's Bash tool runs bash. Always wrap commands that need Vault credentials:

```bash
/bin/zsh -c "source setup-env.sh && terragrunt apply -auto-approve"
```

After sourcing, these env vars are available (verified 2026-06-10):

| Var | Used by |
|-----|---------|
| `MESHSTACK_API_KEY_CLOUDFOUNDATION` | meshstack provider `apisecret` |
| `STACKIT_SKE_PROJECT_SERVICE_ACCOUNT_KEY` | SKE-related modules |
| `STACKIT_S3_ACCESS_KEY_ID` / `STACKIT_S3_SECRET_ACCESS_KEY` | S3-compatible storage |

**`STACKIT_SERVICE_ACCOUNT_KEY_PATH`** is set by `setup-env.sh` itself (pointing to `~/.stackit/credentials.json`) — it is not in Vault because STACKIT's provider doesn't support user-level auth. If the file doesn't exist, `setup-env.sh` will print instructions for creating a STACKIT service account key as a personal-access-token workaround.

---

## Running a Plan

```bash
cd foundations/likvid-prod/<module-path>
/bin/zsh -c "source /Users/jrudolph/dev/mc/likvid-cloudfoundation/setup-env.sh && terragrunt plan"
```

Real example (storage-buckets):

```bash
cd foundations/likvid-prod/platforms/stackit/buildingblocks/storage-buckets
/bin/zsh -c "source /Users/jrudolph/dev/mc/likvid-cloudfoundation/setup-env.sh && terragrunt plan"
```

---

## Applying

```bash
/bin/zsh -c "source /Users/jrudolph/dev/mc/likvid-cloudfoundation/setup-env.sh && terragrunt apply -auto-approve"
```

---

## Building Block Upgrade Workflow (hub module → LCF → e2e smoke test)

This is the full end-to-end process for developing or upgrading a building block hub module and verifying it with a smoke test. All commands are verified 2026-06-10.

### Step 1 — Make and push changes to meshstack-hub

Changes to the building block live in `modules/<provider>/<service>/` in the meshstack-hub repo (`/Users/jrudolph/dev/mc/meshstack-hub`). The `buildingblock/` subdirectory is what meshStack executes per tenant; `backplane/` is the one-time infra setup.

```bash
cd /Users/jrudolph/dev/mc/meshstack-hub
git add modules/<provider>/<service>/...
git commit -m "fix: describe the change"
git push origin <branch>   # e.g. feature/smoke-test-foundations
NEW_REF=$(git rev-parse HEAD)
echo $NEW_REF
```

### Step 2 — Update the LCF git_ref and apply

Hub coordinates are the single source of truth in the module's `hub.hcl`. Update `git_ref` there — the deployment (`main.tf` via `var.hub`) and the sibling `e2e/` both read this one file, so there is nothing to keep in sync:

```hcl
# hub.hcl
locals {
  module    = "stackit/storage-bucket"
  git_ref   = "<new-full-sha>"   # paste $NEW_REF here
  bbd_draft = true
}
```

Then re-init (module source changed) and apply:

```bash
cd foundations/likvid-prod/platforms/<provider>/buildingblocks/<service>
/bin/zsh -c "source /Users/jrudolph/dev/mc/likvid-cloudfoundation/setup-env.sh && terragrunt run -- init -upgrade && terragrunt apply -auto-approve"
```

The apply updates the Building Block Definition in meshStack with the new content hash. Verify the output shows the BBD updated with a new `content_hash`.

### Step 3 — Run the e2e smoke test

The `e2e/` sibling directory sources the hub's own `e2e/` module at the same git ref the deployment uses. The module path + git ref come from the shared `hub.hcl` (via `include "hub" { expose = true }`); the remaining smoke-test inputs (workspace, BBD version_ref) are read from the parent deployment's Terraform outputs.

```bash
cd foundations/likvid-prod/platforms/<provider>/buildingblocks/<service>/e2e
rm -rf .terragrunt-cache   # always clear — stale cache refers to old git ref
/bin/zsh -c "source /Users/jrudolph/dev/mc/likvid-cloudfoundation/setup-env.sh && terragrunt init -upgrade && terragrunt test"
```

Expected output when passing:
```
tests/building_block_<name>_hub.tftest.hcl... pass
  run "building_block_<name>_hub"... pass
Success! 1 passed, 0 failed.
```

---

## Setting Up a New e2e Smoke Test

For a building block that doesn't yet have `e2e/terragrunt.hcl`, create it using this pattern.

**Hub coordinates: single source of truth in `hub.hcl`.** `terraform.source` *must* be a statically-known expression — Terragrunt evaluates it during `--all` module discovery, **before** dependency outputs exist, so reading `dependency.deployment.outputs.*` into `source` fails with `Unsuitable value: value must be known`. Put the module path + git ref in a sibling `hub.hcl` (a plain locals file, statically readable) and `include` it in both the deployment and the e2e config:

**`hub.hcl`** (in the deployment dir, next to `main.tf`):

```hcl
locals {
  module    = "stackit/storage-bucket"
  git_ref   = "<full-sha>"
  bbd_draft = true
}
```

The deployment's `terragrunt.hcl` exposes it and passes it to `main.tf` as `var.hub`:

```hcl
include "hub" {
  path   = "./hub.hcl"   # find_in_parent_folders can't see the current dir; use a relative path
  expose = true
}
inputs = { hub = include.hub.locals }
```

and `main.tf` declares `variable "hub" { type = object({ module = string, git_ref = string, bbd_draft = bool }) }`.

**`e2e/terragrunt.hcl`:**

```hcl
dependency "deployment" {
  config_path = "../"
}

include "hub" {
  path   = "../hub.hcl"
  expose = true
}

terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/${include.hub.locals.module}/e2e?ref=${include.hub.locals.git_ref}"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF

provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "6169f530-0eaa-4f7f-91b7-c4fd4aaf2a74"
  apisecret = "${get_env("MESHSTACK_API_KEY_CLOUDFOUNDATION")}"
}
EOF
}

# Pin meshstack provider to the same version used by the sibling deployment so the hub e2e
# (which has no version constraint) doesn't pick up a newer release incompatible with the
# meshStack instance.
generate "versions_override" {
  path      = "versions_override.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = "~> 0.21.0"
    }
  }
}
EOF
}

# `tofu test` does NOT type-decode complex variables passed via TF_VAR_* env (Terragrunt's default
# mechanism for `inputs`) — they arrive as raw strings in the test assertion scope, which breaks the
# hub assertions that read `var.test_context.name_suffix`. We therefore provide the variables as a
# generated *.auto.tfvars.json, which `tofu test` auto-loads and types correctly. `disable_signature`
# keeps the file valid JSON (no leading "# Generated by Terragrunt" comment).
generate "smoke_tfvars" {
  path              = "smoke.auto.tfvars.json"
  if_exists         = "overwrite"
  disable_signature = true
  contents = jsonencode({
    bbd_version_ref             = dependency.deployment.outputs.building_block_definition.version_ref
    stackit_service_account_key = file("~/.stackit/credentials.json")
    test_context = {
      workspace   = dependency.deployment.outputs.owning_workspace
      name_suffix = run_cmd("--terragrunt-quiet", "date", "-u", "+%Y%m%d%H%M%S")
    }
  })
}
```

**`outputs.tf` in the parent deployment** forwards the hub BBD output verbatim and exposes `owning_workspace` as its own output (the e2e needs it because draft BBDs can only be ordered by the owning workspace):

```hcl
# Forward the hub module's BBD identity verbatim — do NOT reshape it.
output "building_block_definition" {
  description = "BBD identity (uuid + version_ref); referenced by compositions and the sibling e2e/."
  value       = module.<module_name>.building_block_definition
}

# Deployment context, kept separate from BBD identity. Sourced from the deployment's own local.
output "owning_workspace" {
  description = "Workspace that owns this deployment's BBD; required to order it while draft (read by the sibling e2e/)."
  value       = local.meshstack.owning_workspace_identifier
}

output "hub" {
  description = "Hub module path + git ref this deployment uses; read by the sibling e2e/ smoke-test unit."
  value = {
    module  = local.hub_module
    git_ref = local.hub.git_ref
  }
}
```

---

## Upgrading a Hub Module (existing module, no e2e changes)

Hub modules are sourced from `github.com/meshcloud/meshstack-hub.git` at a pinned git ref. To upgrade:

**1. Update the git ref** in `hub.hcl` (the single source of truth, read by both the deployment and the sibling `e2e/`):

```hcl
# hub.hcl
locals {
  git_ref = "<new-full-sha>"
}
```

**2. Check and fix the local provider constraints** in `terraform.tf` (or `versions.tf`) — the new hub module may require newer provider versions. Use `>=` not `~>` so hub and local constraints can be combined:

```hcl
terraform {
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = ">= 0.98.0"
    }
    meshstack = {
      source  = "meshcloud/meshstack"
      version = "~> 0.21.0"   # cap to match your meshStack server version
    }
  }
}
```

**3. Re-init with upgrade** (resolves the lock file):

```zsh
terragruntrun -- init -upgrade
```

**4. Plan and apply**:

```zsh
terragruntplan
terragruntapply
```

---

## Running e2e Smoke Tests

```zsh
cd foundations/likvid-prod/platforms/stackit/buildingblocks/storage-buckets/e2e
terragrunttest
```

The `e2e/terragrunt.hcl` reads outputs from the sibling deployment directory as its dependency — apply the parent module first.

---

## Provider Config Pattern

Modules that need both meshstack and STACKIT providers should generate `provider.tf` via `terragrunt.hcl` (not commit a static file — it gets overwritten). Provider version constraints go in a separate `terraform.tf`:

`terragrunt.hcl`:
```hcl
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "6169f530-0eaa-4f7f-91b7-c4fd4aaf2a74"
  apisecret = "${get_env("MESHSTACK_API_KEY_CLOUDFOUNDATION")}"
}

provider "stackit" {
  experiments = ["iam"]
}
EOF
}
```

`terraform.tf` (separate file, not overwritten):
```hcl
terraform {
  required_providers {
    stackit   = { source = "stackitcloud/stackit",  version = ">= 0.98.0" }
    meshstack = { source = "meshcloud/meshstack",   version = "~> 0.21.0" }
  }
}
```

---

## Gotchas

- **setup-env.sh fails in bash** — `ZSH_VERSION: unbound variable` at line 104. Always source in zsh. Claude Code's Bash tool runs bash; work around with `/bin/zsh -c "source setup-env.sh && ..."`. Use absolute path to `setup-env.sh` to avoid working-directory issues.

- **meshstack provider version cap** — provider `0.22.0` requires meshStack server `2026.24.0+`. If the server is on `2026.23.0`, cap at `~> 0.21.0` in `terraform.tf`. The e2e `terragrunt.hcl` must also generate a `versions_override.tf` with this cap, since the hub's e2e module has no version pin of its own.

- **`tofu test` does not type-decode TF_VAR_* for complex objects** — Terragrunt's `inputs` block passes variables as `TF_VAR_*` env vars. For simple strings this is fine. But for complex object variables like `test_context`, `tofu test` receives a raw string and cannot destructure fields like `var.test_context.name_suffix`. Fix: use `generate "smoke_tfvars"` with `path = "smoke.auto.tfvars.json"` and `disable_signature = true` so the file is valid JSON that `tofu test` auto-loads with proper type decoding.

- **Draft BBD can only be ordered by its owning workspace** — a building block definition in DRAFT state can only have `meshstack_building_block_v2` ordered by the workspace that owns it (the `owned_by_workspace` in the BBD). Ordering from a separate `smoke-test` workspace gets a 403. Always set `test_context.workspace` to the owning workspace, not to a generic smoke-test workspace.

- **Output protocol: forward the BBD verbatim, expose `owning_workspace` separately** — the hub module's `building_block_definition` output is the BBD *identity* (`{ uuid, version_ref }`) and the deployment should forward it **verbatim** (`value = module.<name>.building_block_definition`) — never hand-reshape it. The owning workspace is *deployment context*, not BBD identity, so it gets its own one-line output sourced from the deployment's own local: `output "owning_workspace" { value = local.meshstack.owning_workspace_identifier }`. The sibling `e2e/` reads `dependency.deployment.outputs.owning_workspace` (needed because a draft BBD can only be ordered by its owning workspace). Keeping these two outputs single-purpose is intentional — do not fold the workspace back into the BBD object.

- **Stale e2e cache after hub ref change** — after updating `git_ref` in the parent deployment, always `rm -rf .terragrunt-cache` in the `e2e/` directory before running `terragrunt test`. Terragrunt caches the downloaded e2e module; if the cache was built against the old ref it will run the wrong version.

- **Stale lock file after hub upgrade** — terragrunt copies the committed `.terraform.lock.hcl` into its cache and `terragrunt plan` fails with "locked provider X does not match configured version constraint". Fix: `terragrunt run -- init -upgrade`.

- **`provider.tf` gets overwritten by `generate`** — if `terragrunt.hcl` has a `generate "provider"` block targeting `provider.tf`, any committed `provider.tf` is overwritten (and editing it is pointless — your change vanishes on the next run). Move `terraform { required_providers {} }` to `terraform.tf` instead, and **gitignore the generated `provider.tf`** so it is never committed. The storage-buckets module now has a `.gitignore` with `provider.tf` for exactly this reason (it had previously committed a stale generated file containing a hardcoded `apisecret`).

- **`~> X.Y.0` constraints from hub modules combine unsatisfiably** — `~> 0.88.0` (patch-locked) combined with `>= 0.98.0` (from newer hub module) has no solution. Fix: change the local constraint to `>= 0.88.0` in `terraform.tf`.

- **STACKIT credentials for local dev** — `STACKIT_SERVICE_ACCOUNT_KEY_PATH` is set by `setup-env.sh` to `~/.stackit/credentials.json`. If that file is missing, sourcing `setup-env.sh` will print instructions for creating a STACKIT service account key (the workaround for STACKIT not supporting user-level auth in its provider).

- **meshstack 401 on API key** — the hardcoded `apikey = "6169f530-0eaa-4f7f-91b7-c4fd4aaf2a74"` in `terragrunt.hcl` is paired with `MESHSTACK_API_KEY_CLOUDFOUNDATION` as the secret. A 401 means the key ID and secret don't match (key was rotated). Check the meshStack panel for the current API key ID for the `likvid-prod` service account.

- **meshstack_workspace `smoke-test`** — must exist before deploying modules that reference it. Created manually in meshStack panel if the meshstack module apply fails. The resource is declared in `kit/foundation/meshstack/resources.smoke-test.tf`.

- **include label conflict** — `terragrunt.hcl` with two `include "common"` blocks fails. Each include needs a unique label: use `include "common"` for `common.hcl` and `include "tfstate"` for `tfstate.hcl`. (Already resolved in the storage-buckets module.)

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `ZSH_VERSION: unbound variable` | Use `/bin/zsh -c "source setup-env.sh && ..."` |
| `locked provider X does not match configured version constraint` | `terragrunt run -- init -upgrade` |
| `~> X.Y.0, >= X.Z.0` unsatisfiable | Change local constraint from `~> X.Y.0` to `>= X.Y.0` in `terraform.tf` |
| `unsupported meshStack version: requires 2026.24.0+` | Cap meshstack provider to `~> 0.21.0` |
| `invalid_client` 401 on meshstack | API key ID rotated — update `apikey` in `terragrunt.hcl` |
| `STACKIT_SERVICE_ACCOUNT_TOKEN not set` | `~/.stackit/credentials.json` is missing — source `setup-env.sh` for instructions on creating a STACKIT service account key |
| Building block reached FAILED state | Get the BB UUID from the error message; fetch logs with `node tools/debug/get-bb-run-logs.mjs <uuid>` from meshstack-hub (needs `MESHSTACK_ENDPOINT`, `MESHSTACK_API_KEY`, `MESHSTACK_API_SECRET`) |
| `var.test_context.name_suffix` breaks in tftest assertion | Caused by TF_VAR_* raw-string delivery — use `generate "smoke_tfvars"` with `auto.tfvars.json` instead of `inputs` |
| 403 Forbidden ordering BBD instance | Draft BBD can only be ordered by its owning workspace — set `workspace` to the owning workspace, not `smoke-test` |
| `output ... does not have an attribute` / missing `owning_workspace` in e2e | The parent deployment's `outputs.tf` must expose `output "owning_workspace" { value = local.meshstack.owning_workspace_identifier }` and forward `building_block_definition` verbatim; the e2e reads `dependency.deployment.outputs.owning_workspace` |
| `attributes "update_subscription_name" and "user_lookup_strategy" are required` | Add to `meshstack_platform` Azure replication block (post-v0.18.1) |
| `target_ref.identifier` unknown attribute | Rename to `target_ref.name` (renamed in meshstack provider v0.20.11) |
| `blueprint_service_principal` unsupported | Remove from Azure replication config (removed in v0.20.6) |
| `Invalid Configuration for Read-Only Attribute` on landingzone | Remove `owned_by_workspace` from `metadata` (computed-only field) |
