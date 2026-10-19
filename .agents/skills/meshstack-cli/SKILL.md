---
name: meshstack-cli
description: >
  Work with meshStack from the shell with the `meshstack` CLI: log in, list and debug building
  blocks, definitions and runs, trigger and wait for a run, order a building block. The skill lives
  in the meshstack-cli repository; this file adds the facts of this repository's meshStack.
---

# meshStack CLI

The skill lives in the meshstack-cli repository, the **single source of truth**. Read it before you
run `meshstack`:

> **[meshstack-cli skill](../../../../meshstack-cli/skills/meshstack-cli/SKILL.md)**
> (GitHub: <https://github.com/meshcloud/meshstack-cli/blob/main/skills/meshstack-cli/SKILL.md>)

Keep a sibling checkout at `../meshstack-cli`. Do not copy the skill here.

## This repository's meshStack

| | |
|---|---|
| Endpoint | `https://federation.demo.meshcloud.io` |
| meshPanel | `https://panel.demo.meshcloud.io` |
| Admin workspace | `likvid-cloud` |

The API keys that `setup-env.sh` exports are for Terragrunt. Do not log the CLI in with them.

If `meshstack` is not on `PATH`, look in `~/go/bin`, where `go install` puts it.
