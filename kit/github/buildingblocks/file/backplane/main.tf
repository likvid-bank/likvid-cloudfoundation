# Place your module's terraform resources here as usual.
# Note that you should typically not put a terraform{} block into cloud foundation kit modules,
# these will be provided by the platform implementations using this kit module.
data "bitwarden_item_login" "github_app" {
  search = "github-app/building-blocks"
}

data "bitwarden_attachment" "github_app_pem_file" {
  id      = data.bitwarden_item_login.github_app.attachments[0].id
  item_id = data.bitwarden_item_login.github_app.id
}
