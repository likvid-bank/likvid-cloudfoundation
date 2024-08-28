output "documentation_md" {
  value = <<EOF
# M25 Platform

Likvid Bank acquired M25 as a "digital native" bank in 2024. We are currently undergoing post-merger integration.
As part of the integration strategy, the board has decided that M25 will retain its own dedicated IT platform
based on AWS.

However, the Likvid Bank Cloud Foundation team has been tasked with integrating M25's AWS environment into our
"payer account" to enable global cost optimization and security posture management.

## AWS Organization Setup

This platform is managed by the M25 Platform team underneath OU `${aws_organizations_organizational_unit.platform.id}`.

The M25 Platform is owned by a meshStack workspace called `m25-platform`. This workspace is a "Landing Zone Contributor"
to our AWS platform.
EOF
}
