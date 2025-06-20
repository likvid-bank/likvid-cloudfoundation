---
mode: agent
---

Use instructions from the file `.github/instructions/demo_story.instructions.md` to write a demo story for the Likvid Bank Cloud Foundation.

Ask the user for relevant information to fill in the template.

Use a concise and clear writing style.
Make sure to use consistent terminology for the same concepts, especially when referring to meshStack concepts 
like "Workspace", "Landing Zone", "Building Block Definition", etc.

Scan the terraform code in the `kit/foundation/meshstack/` directory to find available managed terraform resources
and whenever possible include values from these resources via string interpolation (via template variables defined 
in the `locals.md_contents` local). Make necessary edits to surface additional variables that are not already defined in
 the `locals.md_contents` local to the templates.

When referring to workspaces, use deep-links into meshPanel to the relevant workspace, e.g. `${md_workspace_m25_platform_team}`.
This helps someone following the demo story to quickly navigate to the relevant workspace in meshPanel.

When asked to refactor an existing demo story, you may find that they do not follow the best practices outlined before.
In this case, suggest edits and improvements to the existing demo story to align it with the best practices.