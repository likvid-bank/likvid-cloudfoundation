module "this" {
  source = "github.com/meshcloud/meshstack-hub//reference-architectures/stackit-landingzone-accelerator?ref=${var.hub.git_ref}"

  meshstack = {
    owning_workspace_identifier = "stackit-platform"
  }

  tags = {
    landingzone = [
      { key = "LandingZoneFamily", values = ["cloud-native"] },
      { key = "environment", values = ["dev", "qa", "test", "prod"] },
      { key = "confidentiality", values = ["internal", "public"] },
    ]
    building_block = [{ key = "LandingZoneClearance", values = ["cloud-native"] }]
  }

  hub = var.hub
}

output "building_block_definition" {
  value = module.this.building_block_definition
}
