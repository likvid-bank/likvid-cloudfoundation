output "repository_html_url" {
  value       = data.github_repository.static_website_assets.html_url
  description = "The HTML URL of the GitHub repository hosting the static website assets demos"
}

locals {
  template_vars = {
    
  }
}
output "documentation_guides_md" {
  value = {
    "guide_meshkube" : templatefile(
      "${path.module}/guide_gitops_github.md",
      merge(var.documentation_vars, local.template_vars)
    )
  }
}