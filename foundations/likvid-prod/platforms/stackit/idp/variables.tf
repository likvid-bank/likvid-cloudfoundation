# as this is a secret, we need to get this from an env var, see init.sh
variable "gitea_token" {
  type      = string
  sensitive = true
}
