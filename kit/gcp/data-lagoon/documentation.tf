output "documentation_md" {
  value = <<EOF
This module manages likvid's data warehouse infrastructure. The project is internally called data lagoon.

Architecturally, data lagoon stays close to Google's official Jump Start Solution pattern.
For a detailed reference visit [Google's Cloud Architecture Center](https://cloud.google.com/architecture/big-data-analytics/data-warehouse).
EOF
}
