---
name: meshstack-cli
description: >
  Query meshStack from the shell with the `meshstack` CLI. Covers login and profiles, the
  `-o ndjson | jq` pipeline, the meshObject shape (metadata/spec/status) that makes filtering
  cheap, and how to look up shapes the CLI does not print in the meshStack OpenAPI spec.
  Use when asked to list, inspect or debug workspaces, building blocks, building block
  definitions or building block runs, or to report on the health of the building blocks a
  platform team provides. Also covers preflight runs and approvals, meshPanel deep links, waiting
  for a run, and ordering a building block through the REST API.
---

# meshStack CLI

The CLI is a read-only window into meshStack today. Everything it can do:

| Command | Alias | Lists |
|---|---|---|
| `meshstack workspace list` | | workspaces this login can see |
| `meshstack buildingblock list` | `bb` | building blocks (deployed instances) |
| `meshstack buildingblockdefinition list` | `bbd` | definitions — what platform teams offer |
| `meshstack buildingblockdefinitionversion list --definition <uuid>` | `bbdv` | the versions of one definition |
| `meshstack buildingblockrun list [--building-block <uuid>]` | `bbrun` | runs, newest last, per block |
| `meshstack buildingblockrun logs <run-uuid>` | `bbrun` | the steps of one run, with their output |

The `bbd`, `bbdv` and `logs` commands are marked **experimental** — their output shape may still
change, so re-check a field before trusting a stale recipe.

Creating or changing anything goes through Terraform, not this CLI. The exception is a one-off order
that Terraform cannot converge on, such as a starterkit: see
[Ordering a building block through the REST API](#ordering-a-building-block-through-the-rest-api).

## Setup

The binary is installed with `go install` from `github.com/meshcloud/meshstack-cli` and lands in
`~/go/bin`, which is **not** on `PATH` in this environment. Call it as `~/go/bin/meshstack`, or
export the path once per shell.

```sh
export PATH="$HOME/go/bin:$PATH"
```

Login stores a credential in a profile (`~/Library/Application Support/meshstack/` on macOS,
`$XDG_CONFIG_HOME/meshstack/` elsewhere). Check for a live session by running any `list` command
before you ask the user to log in.

```sh
meshstack login                         # browser login, needs a human
meshstack login --apikey <id> --stdin   # API key, secret from stdin
meshstack login --apitoken --stdin      # an access token, sent as it is
meshstack auth logout                   # drop this profile's credential
```

`--endpoint`, `--workspace`, `--profile` and `--skip-version-check` are global flags with
`MESHSTACK_`-prefixed env equivalents.

## Selecting the workspace

`--workspace` is a global flag, so it goes on any command. It takes the workspace identifier as
meshPanel shows it (`metadata.name`, e.g. `devops-platform`), not the display name.

```sh
meshstack bb list --workspace devops-platform -o ndjson
```

**Scope comes from the flag, not from the profile.** Without `--workspace`, `bb list` returns every
block the login can reach across all workspaces — this is the view a platform team wants when
managing all BBs deployed from the BBDs that it owns. Pass `--workspace` to filter only on one
specific workspace. On `bbd list` the flag means *owned by* that workspace; without it you also get
the definitions published across the platform.

A workspace the login cannot reach **errors**; it does not come back empty:

```
Error: no access to workspace 'banking-2-0': ... minted a token for workspace '<none>' instead
```

So a short result means you narrowed the scope yourself, and a missing workspace means a wrong
identifier rather than a permission gap.

## Always pipe ndjson through jq

Default output is YAML for humans. For anything you consume yourself, use `-o ndjson`: one JSON
object per line, so `jq` filters stream and you never parse YAML.

```sh
meshstack bb list -o ndjson | jq -r '...'
```

**The payload is much bigger than it looks.** A single building block carries every input, every
output and a `summary` output holding a full markdown report; a hundred of them run to ~90 KB. A
`bbd list` is far worse: every definition embeds its icon as a base64 `spec.symbol`, which is ~80%
of a 1.4 MB response. Never pipe a raw list into your context. Project the two or three fields you
need in the same command that fetches them — and project with `jq`, not with `head`, which
truncates mid-object and makes the filter fail silently.

## The meshObject shape

Every object the CLI prints has the same three top-level keys, so one mental model covers all of
them:

```
metadata   identity — thinner than you expect, see below
spec       desired state — what someone asked for
status     observed state — what meshStack made of it
```

Field names worth knowing:

- **Workspace** — `metadata.name` is the identifier used everywhere else (e.g. `agentic-platform`),
  `spec.displayName` is prose. `metadata` also carries `createdOn`, `deletedOn` and `tags`.
- **Building block** — `metadata` carries **only** `uuid` and `ownedByWorkspace`. Everything else
  lives in `spec.displayName`, `spec.buildingBlockDefinitionVersionRef.uuid`, `spec.targetRef.kind`
  (`meshWorkspace` or `meshTenant`), `status.status`, `status.lifecycle.state`,
  `status.latestRunUuid`, `status.latestDryRunUuid`, `status.forcePurge`.
- **Definition** — `metadata.uuid`, `metadata.ownedByWorkspace`, `spec.displayName`,
  `spec.targetType` (`TENANT_LEVEL` or `WORKSPACE_LEVEL`), `spec.supportedPlatforms[]`,
  `spec.approvalPolicies`, `spec.schedule`, and the huge `spec.symbol`. `status.versions[]` maps
  `versionUuid` to `versionNumber` and `state`; `status.latestReleasedVersionUuid` names the
  current one.
- **Definition version** — `metadata.uuid` is the uuid a building block's
  `spec.buildingBlockDefinitionVersionRef` points at. `spec.versionNumber`, `spec.state`,
  `spec.deletionMode`, `spec.implementation.terraform` (`repositoryUrl`, `repositoryPath`,
  `refName`, `terraformVersion`), and `spec.inputs` / `spec.outputs` as maps of name to a
  declaration (`displayName`, `type`, `assignmentType`, `isSensitive`, `argument` for a statically
  bound value). `status.usageCount` counts the blocks on that version.
- **Run** — `metadata.uuid`, `spec.runNumber`, `spec.behavior` (`APPLY`, `DETECT`), `status` (a
  plain string here, not an object). `spec.buildingBlock` repeats the block's placement, but its
  `projectIdentifier` and `fullPlatformIdentifier` are usually null — prefer the block's own
  `metadata.ownedByWorkspace`.
- **Run logs** — not a meshObject and not one line per item: a single object with a `steps[]` array
  of `{displayName, status, userMessage, systemMessage}`. `systemMessage` is the raw runner output,
  `userMessage` the condensed message shown to the consumer.

Traps worth knowing before you read any of it:

**`status.lifecycle` is the meshObject-wide convention for state and its transitions**, the same
shape on meshTenant, meshPlatform, meshLandingZone and the rest:

```
status.lifecycle.state                        ACTIVE | MARKED_FOR_DELETION | DELETED
status.lifecycle.created.timestamp            ISO-8601, e.g. 2020-12-22T09:37:43Z
status.lifecycle.markedForDeletion.timestamp  present once deletion was requested
status.lifecycle.deleted.timestamp            present once deletion completed
```

Each transition also carries an `author` (`type` is `User`, `ApiKey`, `ApiUser` or `System`, plus
`displayName` and `email` for real users), so the API can say who requested a deletion.

**The CLI does not print any of it except `state`.** It asks for the v1 representation and flattens
lifecycle to `{"state": "..."}`; the timestamps and authors live on the `v2-preview` media type
(`application/vnd.meshcloud.api.meshbuildingblock.v2-preview.hal+json`), which the CLI cannot
request and which has no passthrough command. A run's `metadata.createdOn` also comes back empty.
So **from the CLI alone you cannot age a failure or say who triggered a run** — `spec.runNumber` is
the only ordering available. Say so rather than guessing, and reach for the REST API when the
question really is "when" or "who".

**`status.lifecycle.state` decides whether a failure matters.** `ACTIVE` means someone still depends
on the block. `MARKED_FOR_DELETION` means it is on its way out, and a failure there is usually a
destroy that did not finish — noise in a health report, not an incident. Always project this field
next to `status.status`, or you will report several times more problems than exist.

**`spec.displayName` on a building block is user-chosen, not the definition name.** Consumers rename
their instances, so a single definition version turns up under a dozen unrelated names. To group
blocks by *what the platform team provides*, key on `spec.buildingBlockDefinitionVersionRef.uuid`
and treat displayName as a label. `bbd list` resolves that uuid to a real name — see the recipe
below.

`spec.inputs` and `status.outputs` on a building block are maps of name to
`{value, valueType, assignmentType, isSensitive}`. So `spec.inputs.project_name.value` is the value;
`spec.inputs.project_name` alone is four times the tokens.

## Recipes

One line per building block — start here, then drill into a single uuid:

```sh
meshstack bb list -o ndjson |
  jq -r '[.metadata.uuid, .metadata.ownedByWorkspace, .spec.displayName,
          .status.status, .status.lifecycle.state] | @tsv'
```

Failures that actually need attention — anything still `ACTIVE`:

```sh
meshstack bb list -o ndjson |
  jq -r 'select(.status.status != "SUCCEEDED" and .status.lifecycle.state == "ACTIVE") |
         [.metadata.uuid, .metadata.ownedByWorkspace, .spec.displayName,
          .status.latestRunUuid] | @tsv'
```

The definitions on offer, one line each — drop `spec.symbol` or you pull a megabyte of base64:

```sh
meshstack bbd list -o ndjson |
  jq -r '[.metadata.uuid, .metadata.ownedByWorkspace, .spec.displayName,
          .spec.targetType, (.status.latestReleasedVersion|tostring)] | @tsv'
```

Fleet health per definition version, with readable names. `bbd list` carries the whole
version-uuid-to-name map, so build it once and join the block list against it:

```sh
meshstack bbd list -o ndjson |
  jq -r '.spec.displayName as $n | .status.versions[] |
         [.versionUuid, "\($n) v\(.versionNumber)"] | @tsv' | sort > /tmp/bbdv-names.tsv

meshstack bb list -o ndjson |
  jq -r '[.spec.buildingBlockDefinitionVersionRef.uuid, .status.status] | @tsv' | sort |
  join -t $'\t' - /tmp/bbdv-names.tsv | cut -f2,3 | sort | uniq -c | sort -rn
```

Which hub module and Git ref a definition's versions are pinned to — the fastest way to see whether
a deployed BBD lags the foundation's `ref=`:

```sh
meshstack bbdv list --definition <definition-uuid> -o ndjson |
  jq -r '.spec.implementation.terraform as $t |
         [.spec.versionNumber, .spec.state, (.status.usageCount|tostring),
          $t.repositoryPath, $t.refName] | @tsv' | sort -n
```

`refName` is empty on older versions that were not pinned to a commit.

What a definition version declares as inputs, and which of them the platform team binds statically:

```sh
meshstack bbdv list --definition <definition-uuid> -o ndjson |
  jq -r 'select(.spec.versionNumber == <n>) | .spec.inputs | to_entries[] |
         "\(.key)\t\(.value.type)\t\(.value.assignmentType)"'
```

Inputs of a deployed block as flat `name=value` pairs, sensitive ones masked:

```sh
meshstack bb list -o ndjson |
  jq -r 'select(.metadata.uuid == "<uuid>") | .spec.inputs |
         to_entries[] | "\(.key)=\(if .value.isSensitive then "<sensitive>" else .value.value end)"'
```

Outputs without the giant markdown report:

```sh
meshstack bb list -o ndjson |
  jq -r 'select(.metadata.uuid == "<uuid>") | .status.outputs |
         del(.summary) | to_entries[] | "\(.key)=\(.value.value)"'
```

The `summary` output is a rendered markdown report. Read it deliberately, on its own, and only when
you need the human-facing story:

```sh
meshstack bb list -o ndjson |
  jq -r 'select(.metadata.uuid == "<uuid>") | .status.outputs.summary.value'
```

Run history for one block:

```sh
meshstack bbrun list --building-block <uuid> -o ndjson |
  jq -r '[.metadata.uuid, (.spec.runNumber|tostring), .spec.behavior, .status] | @tsv'
```

Why a run failed — only the steps that broke, and their consumer-facing message:

```sh
meshstack bbrun logs <run-uuid> -o ndjson |
  jq -r '.steps[] | select(.status != "SUCCEEDED") |
         "== \(.displayName) [\(.status)]\n\(.userMessage // .systemMessage)"'
```

`systemMessage` on a successful step holds the full `tofu init`/`apply` transcript and runs to tens
of kilobytes. Read one step at a time when you need it:

```sh
meshstack bbrun logs <run-uuid> -o ndjson |
  jq -r '.steps[] | select(.displayName == "Run Terraform Apply") | .systemMessage'
```

## Approval gates and preflight runs

A definition with `approval_policies` does not apply a gated change straight away. meshStack first
runs a **preflight**: a dry run, listed with `spec.behavior == "DETECT"`. The `APPLY` run after it
parks in `WAITING_FOR_APPROVAL` until someone approves it in meshPanel. The approver sees the
preflight's plan, so read it yourself before you ask for the approval:

```sh
meshstack bbrun logs <preflight-run-uuid> -o ndjson |
  jq -r '.steps[].systemMessage // ""' |
  grep -E "will be (created|destroyed|updated|replaced)|must be replaced|Plan:"
```

Report the `Plan:` line and anything unexpected, and hand the user a deep link (below). A
Terraform apply that updates such a block ends with the provider warning `Building block run is
waiting for input or approval` — that is the gate, not an error.

## Linking into meshPanel

Give the user a link whenever you ask them to act in meshPanel. A building block, by uuid:

```
https://panel.demo.meshcloud.io/#/s/<workspace>/building-blocks/building-blocks-overview?healthStatus=NONE,SUCCEEDED,FAILED&buildingBlock=<uuid>
```

meshPanel's own links carry the numeric id of meshStack's internal API instead of the uuid. That id
is not exposed to an API key, so do not try to build those.

## Waiting for a run

Poll the block's status until it reaches a terminal state, and emit only on change. Every terminal
state has to end the loop, or a failure looks like a run that is still going:

```sh
B=<uuid>; prev=""
while true; do
  s=$(meshstack bb list --workspace <workspace> -o ndjson 2>/dev/null |
      jq -r "select(.metadata.uuid==\"$B\") | .status.status" || true)
  [ -n "$s" ] && [ "$s" != "$prev" ] && echo "block status: $s" && prev=$s
  case "$s" in SUCCEEDED|FAILED|ABORTED) exit 0;; esac
  sleep 30
done
```

A block that deletes itself at the end of its run, like a starterkit, drops out of `bb list`. Poll
its runs instead: `meshstack bbrun list --building-block $B` until the `APPLY` run is terminal.

## Ordering a building block through the REST API

Log in with the foundation's API key (see the `foundation-modules` skill for the secret). `/api/login`
redirects to the SSO token endpoint, so follow it with `-L`:

```sh
E=https://federation.demo.meshcloud.io
T=$(curl -sL -X POST "$E/api/login" \
  --data-urlencode grant_type=client_credentials \
  --data-urlencode client_id=6169f530-0eaa-4f7f-91b7-c4fd4aaf2a74 \
  --data-urlencode "client_secret=$MESHSTACK_API_KEY_CLOUDFOUNDATION" | jq -r .access_token)
```

Look up the definition version uuid and the `USER_INPUT` inputs with the `bbdv list` recipe above,
then post the order. A workspace-level block targets `{kind: "meshWorkspace", name: <workspace>}`;
a tenant-level one targets `{kind: "meshTenant", uuid: <tenant-uuid>}`:

```sh
MT=application/vnd.meshcloud.api.meshbuildingblock.v2-preview.hal+json
jq -n '{apiVersion: "v2-preview", kind: "meshBuildingBlock", spec: {
    displayName: "my-project",
    buildingBlockDefinitionVersionRef: {kind: "meshBuildingBlockDefinitionVersion", uuid: "<version-uuid>"},
    targetRef: {kind: "meshWorkspace", name: "<workspace>"},
    inputs: {name: {value: "my-project", valueType: "STRING"}}}}' |
  curl -s -X POST -H "Authorization: Bearer $T" -H "Content-Type: $MT" -H "Accept: $MT" -d @- \
    "$E/api/meshobjects/meshbuildingblocks" | jq -c '{uuid: .metadata.uuid, status: .status.status}'
```

A block ordered with an API key has an `ApiKey` author, so a starterkit grants nobody Project Admin.
A draft definition version can only be ordered in the workspace that owns it.

## Shapes the CLI does not print

The CLI covers five kinds, and prints an older representation of them. The question it still cannot
answer — **when or by whom anything happened** — plus everything about tenants, project bindings and
tags, lives in the meshStack OpenAPI spec:

<https://docs.meshcloud.io/api/meshstack-openapi-docs.json>

It is ~4.5 MB. **Never read it whole.** Download once, then query it with `jq`:

```sh
curl -sS -o /tmp/meshstack-api.json https://docs.meshcloud.io/api/meshstack-openapi-docs.json
jq -r '.paths | keys[]' /tmp/meshstack-api.json | grep -i definition
jq '.components.schemas.meshBuildingBlockV2.properties.status.properties.lifecycle' /tmp/meshstack-api.json
```

Endpoints are versioned through the `Accept` header, not the URL, so read the media type from the
path's response `content` map rather than guessing one. The richer shapes are often on a
`v2-preview` type while the CLI still asks for `v1`.
