resource "github_repository" "this" {
  name        = "aks-app-template"
  description = "AKS application template with HAProxy ingress and cert-manager TLS"
  visibility  = "public"
  is_template = true
  auto_init   = true

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  template_files = {
    ".dockerignore"                                 = file("${path.module}/content/.dockerignore")
    ".gitignore"                                    = file("${path.module}/content/.gitignore")
    ".github/workflows/k8s-deploy.yml"              = file("${path.module}/content/dotgithub/workflows/k8s-deploy.yml")
    "README.MD"                                     = file("${path.module}/content/README.MD")
    "backend/Dockerfile"                            = file("${path.module}/content/backend/Dockerfile")
    "backend/index.js"                              = file("${path.module}/content/backend/index.js")
    "backend/package.json"                          = file("${path.module}/content/backend/package.json")
    "frontend/Dockerfile"                           = file("${path.module}/content/frontend/Dockerfile")
    "frontend/.editorconfig"                        = file("${path.module}/content/frontend/.editorconfig")
    "frontend/.gitignore"                           = file("${path.module}/content/frontend/.gitignore")
    "frontend/angular.json"                         = file("${path.module}/content/frontend/angular.json")
    "frontend/package.json"                         = file("${path.module}/content/frontend/package.json")
    "frontend/README.md"                            = file("${path.module}/content/frontend/README.md")
    "frontend/src/app/app.config.ts"                = file("${path.module}/content/frontend/src/app/app.config.ts")
    "frontend/src/app/app.html"                     = file("${path.module}/content/frontend/src/app/app.html")
    "frontend/src/app/app.routes.ts"                = file("${path.module}/content/frontend/src/app/app.routes.ts")
    "frontend/src/app/app.scss"                     = file("${path.module}/content/frontend/src/app/app.scss")
    "frontend/src/app/app.spec.ts"                  = file("${path.module}/content/frontend/src/app/app.spec.ts")
    "frontend/src/app/app.ts"                       = file("${path.module}/content/frontend/src/app/app.ts")
    "frontend/src/environments/environment.prod.ts" = file("${path.module}/content/frontend/src/environments/environment.prod.ts")
    "frontend/src/environments/environment.ts"      = file("${path.module}/content/frontend/src/environments/environment.ts")
    "frontend/src/index.html"                       = file("${path.module}/content/frontend/src/index.html")
    "frontend/src/main.ts"                          = file("${path.module}/content/frontend/src/main.ts")
    "frontend/src/styles.scss"                      = file("${path.module}/content/frontend/src/styles.scss")
    "frontend/tsconfig.app.json"                    = file("${path.module}/content/frontend/tsconfig.app.json")
    "frontend/tsconfig.json"                        = file("${path.module}/content/frontend/tsconfig.json")
    "frontend/tsconfig.spec.json"                   = file("${path.module}/content/frontend/tsconfig.spec.json")
    "k8s/angular-deployment.yml"                    = file("${path.module}/content/k8s/angular-deployment.yml")
    "k8s/angular-service.yml"                       = file("${path.module}/content/k8s/angular-service.yml")
    "k8s/ingress.yml"                               = file("${path.module}/content/k8s/ingress.yml")
    "k8s/nodejs-deployment.yml"                     = file("${path.module}/content/k8s/nodejs-deployment.yml")
    "k8s/nodejs-service.yml"                        = file("${path.module}/content/k8s/nodejs-service.yml")
  }
}

resource "github_branch" "release" {
  repository    = github_repository.this.name
  branch        = "release"
  source_branch = "main"

  depends_on = [github_repository_file.template_files]
}

resource "github_repository_file" "template_files" {
  for_each   = local.template_files
  repository = github_repository.this.name
  file       = each.key
  content    = each.value
  branch     = "main"

  commit_message      = "chore: initialize template"
  commit_author       = "likvid-cloudfoundation"
  commit_email        = "platform@likvid-bank.com"
  overwrite_on_create = true

}
