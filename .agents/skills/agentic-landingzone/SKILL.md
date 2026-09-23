---
name: agentic-landingzone
description: >
  Propose and roll out a change to the agentic STACKIT landing zone
  (foundations/likvid-prod/platforms/stackit/agentic-landingzone): edit the architecture, pin it,
  apply, review the preflight, get the run approved and verify it with a starterkit order. Use when
  asked to add a building block to this landing zone, give every new project something, or change
  anything the landing zone registers.
---

# Agentic STACKIT Landing Zone

The unit deploys one building block, the landing zone architecture, into the `agentic-platform`
workspace. meshStack runs the architecture's code, and every run of it waits for a platform
engineer's approval. Your job is to propose the change as commits and get it to that
approval with a clean preflight.

## Layout

| Path | What it is |
|---|---|
| `variables.tf` | Pins, as defaults: `hub.git_ref` for all nested hub modules, `buildingblock_git_ref` for the code meshStack runs |
| `meshstack_integration.tf` | The architecture's definition: inputs, approval gates, the readme shown in meshPanel |
| `main.tf` | The one building block instance and its inputs |
| `provider.tf` | Runs as the user's meshStack CLI login. No secret, no Terragrunt, state in a local `terraform.tfstate` |
| `buildingblock/` | The architecture meshStack runs. Registers the platform, landing zones and nested definitions |
| `buildingblock/stackit-project-starterkit/` | Fork of the hub starterkit. Runs from the same commit as the architecture |

## Rollout loop

The unit is plain OpenTofu. It needs the user's `meshstack login` and `tofu` from the nix devShell
(`nix develop <repo> --command tofu ...`), and neither Vault nor gcloud. The meshStack reads come
from the `meshstack-cli` skill.

1. **Edit** `buildingblock/`. Update the definition readme in `meshstack_integration.tf` and
   `README.md` in the same commit when you change what the architecture registers.
2. **Validate offline.** Copy the directory to the scratchpad so no `.terraform/` lands in the repo.
   `hub` is a `const` variable, so `init` needs it too:

   ```bash
   H='hub={git_ref="<hub.git_ref from variables.tf>",bbd_draft=true}'
   cp -R buildingblock <scratch>/bb && cd <scratch>/bb
   tofu init -backend=false -var="$H" >/dev/null && tofu validate -var="$H"
   ```

   Validate `buildingblock/stackit-project-starterkit/buildingblock` the same way (no `hub` var).
   Run `tofu fmt -check -recursive` on the unit.
3. **Commit, then pin.** meshStack checks out `buildingblock_git_ref` from GitHub. Commit the change,
   move `buildingblock_git_ref` onto that commit in a second commit, and push both.
4. **Plan and apply** the unit: `tofu plan -out=plan.tfplan`, then `tofu apply plan.tfplan`. Expect
   `2 to change`: the definition (new `ref_name`) and the block. Anything else is a surprise to
   explain before you apply.
5. **Read the preflight.** Find the newest `DETECT` run of the block and read its plan (recipe in
   `meshstack-cli`, § Approval gates and preflight runs). Look up the block's uuid with
   `meshstack bb list --workspace agentic-platform`, display name `Agentic STACKIT Landing Zone`.
6. **Ask for the approval** with the plan summary and a meshPanel deep link to the block. Then wait
   for a terminal status (`meshstack-cli`, § Waiting for a run).
7. **Verify** a change that affects projects by ordering the starterkit
   (`meshstack-cli`, § Ordering a building block).

## Local state

`terraform.tfstate` exists only on the machine that last applied the unit. Without it, a plan wants
to create the definition and the block again. Import both by uuid instead
(`tofu import meshstack_building_block_definition.this <uuid>`, the same for
`meshstack_building_block.this`), or delete the block in meshPanel and let the apply recreate it.

## Moving `hub.git_ref`

Every nested hub definition carries the ref in its `symbol` URL and its `ref_name`. Moving it
updates all of them in place, even where the module code is identical, and that noise lands in the
preflight the approver reviews. Move the pin as its own rollout before a change that needs a newer
hub module. Check first that the hub actually has the module at the ref:
`git -C ../meshstack-hub ls-tree <ref> modules/stackit/`.

## Patterns

**Register a hub building block definition.** Add a module to `buildingblock/main.tf` the way
`service_account_integration` does: source the hub at `${var.hub.git_ref}`, put its backplane in the
foundation project, and pass `var.tags.building_block` and `var.hub`. Names that are unique per
STACKIT organization, such as a custom role, need a suffix: other landing zones share the
organization.

**Give every new project a building block.** Order it in the fork's `buildingblock/this/main.tf`
as a `meshstack_building_block` targeting `meshstack_tenant.this.ref`, like the spoke network.
Hand the definition version in from the architecture as a `STATIC` input. The value has to be
threaded through four places: the fork's `meshstack_integration.tf` (variable and input),
`buildingblock/variables.tf`, `buildingblock/main.tf` and `buildingblock/this/variables.tf`. Add it
to the fork's readme and summary too. Only projects created through the starterkit get it, not
projects created against the landing zone directly.
