# Agent Instructions — likvid-cloudfoundation

The cloud foundation IaC for Likvid Bank: a Terragrunt monorepo defining the internal developer
platform. Modules live under `foundations/likvid-prod/`. See [README.md](README.md) for the project
overview and cloud auth setup.

## Skills

Discover task-specific skills under [`.agents/skills/`](.agents/skills/) (the `.claude/` directory is
a symlink to `.agents/`, so Claude Code and other agents share the same skills):

- **[`run-lcf-modules`](.agents/skills/foundation-modules/SKILL.md)** — run/plan/apply/upgrade
  Terragrunt modules, credential setup, fixing provider/credential errors.
- **[`hub`](.agents/skills/hub/SKILL.md)** — work with [meshstack-hub](https://github.com/meshcloud/meshstack-hub)
  modules: consume them as deployed building blocks and run foundation e2e smoke tests. Links to the
  hub's `e2e-test` skill, the **single source of truth** for the e2e invocation protocol.

## Conventions

- **Terragrunt + OpenTofu.** Use `terragrunt` / `tofu` (not `terraform`); tooling comes from the nix
  devShell (`nix develop`).
- **Credentials first.** `setup-env.sh` must be sourced in zsh (see the `run-lcf-modules` skill).
- **Hub modules are pinned by Git ref.** Source hub modules via
  `git::https://github.com/meshcloud/meshstack-hub.git//modules/<path>?ref=<sha>` — never re-implement
  hub logic in the foundation; the foundation is a shim that references hub modules.
