---
mode: agent
---

Use instructions from the file `.github/instructions/cleanup.instructions.md` to clean up meshStack workspaces
and their contained resources.

Ask the user for the workspace name prefix to filter on (e.g. "kubecon"). Only workspaces whose identifier
starts with that prefix will be considered for deletion.

Before making any destructive API calls, always present a clear summary of what will be deleted and ask the user
for explicit confirmation.

Load environment variables from the `.env-cleanup` file at the repository root before starting.

When deleting multiple workspaces, work in parallel using concurrent tool calls to maximize efficiency.
