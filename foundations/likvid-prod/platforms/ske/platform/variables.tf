variable "hub" {
  type = object({
    git_ref   = string
    bbd_draft = bool
  })
}

variable "additional_federated_building_block_definitions" {
  type = list(object({
    kind = string
    uuid = string
  }))
  description = "Refs of definitions registered on top of the platform whose runs act as its automation service account."
}
