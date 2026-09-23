variable "building_block_definition" {
  type = object({
    uuid        = string
    version_ref = object({ uuid = string })
  })
  description = "STACKIT Kubernetes Platform definition from ../landingzone."
}
