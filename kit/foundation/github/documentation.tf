output "documentation_md" {
  value = <<EOF
# GitHub Actions Automation
We automate validation and deployment of our cloud foundation IaC code on the GitHub repo [${data.github_repository.cloudfoundation.full_name}](${data.github_repository.cloudfoundation.html_url})
via GitHub Actions.
> We enable GitHub actions to access our cloud platforms using workload identity federation.
## Actions Environment Variables
This module sets up the following environment variables for the GitHub Actions workflow in the `${var.foundation}` environment:
${join("\n", formatlist("- %s", keys(var.actions_variables)))}
EOF
}
