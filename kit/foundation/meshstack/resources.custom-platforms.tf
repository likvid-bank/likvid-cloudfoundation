## Application Team

# Need to first create the tenant manually in meshStack UI before applying, since we cannot create tenants with user inputs for custom platforms yet.
resource "meshstack_tenant" "m25_online_banking_app_docs_repo" {
  metadata = {
    platform_identifier = "github-repository.devtools"
    owned_by_project    = meshstack_project.m25_online_banking_app.metadata.name
    owned_by_workspace  = terraform_data.meshobjects_import["workspaces/m25-online-banki.yml"].output.metadata.name
  }
  spec = {
    landing_zone_identifier = "github-repository"
  }
}
