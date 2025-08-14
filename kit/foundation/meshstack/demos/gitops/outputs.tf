output "repository_html_url" {
  value       = data.github_repository.static_website_assets.html_url
  description = "The HTML URL of the GitHub repository hosting the static website assets demos"
}

locals {
  template_vars = {
    static_website_assets_repo_url = data.github_repository.static_website_assets.html_url,
    # todo: replace this once we have BBD API
    buildingBlockDefinitions_m25-static-website-assets_spec_displayName = "Static Website Assets (GitHub)",
  }
}
output "documentation_guides_md" {
  value = {
    "guide_gitops_github" : templatefile(
      "${path.module}/guide_gitops_github.md",
      merge(var.documentation_vars, local.template_vars)
    )
  }
}