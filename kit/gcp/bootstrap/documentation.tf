output "documentation_md" {
  value = <<EOF
# Cloud Foundation Deployment

The foundation-level resources are deployed to the GCP project with project id `${var.foundation_project_id}`.

## Automation

The Service Account `${google_service_account.validation.email}` has been set up for the automated validation a GitHub actions pipeline.
This user has read-only access to terraform state and read only access to the entire landing zone architecture.

GitHub actions can authenticate as this service account using Workload Identity Federation

## Platform Engineer Access Management

The `${var.platform_engineers_group.name}` group is used to grant privileged access to members of the
cloud foundation team. The group has the following members:

${join("\n", formatlist("- %s", var.platform_engineers_group.members))}

EOF
}
