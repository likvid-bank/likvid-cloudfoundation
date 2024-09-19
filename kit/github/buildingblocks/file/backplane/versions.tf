terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.42.0"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = ">=0.8.0"
    }
  }
}
