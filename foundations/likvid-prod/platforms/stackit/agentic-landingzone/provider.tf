# Runs as whoever is logged in to the meshStack CLI (`meshstack login`), so a change is authored by
# the person who asked for it, and no secret is needed.
provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  workspace = local.workspace
}
