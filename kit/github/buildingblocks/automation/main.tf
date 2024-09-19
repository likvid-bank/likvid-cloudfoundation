# Place your module's terraform resources here as usual.
# Note that you should typically not put a terraform{} block into cloud foundation kit modules,
# these will be provided by the platform implementations using this kit module.
resource "tls_private_key" "building_block_implementation" {
  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "building_block_implementation" {
  title      = "Building Block implementation (${var.foundation})"
  repository = "internal-cloudfoundation"
  key        = tls_private_key.building_block_implementation.public_key_openssh
  read_only  = true
}
