output "documentation_md" {
  value = <<EOF
# IONOS meshcloud Users

${join("\n", formatlist("- `%s`", [for u in var.users : u.email]))}

# IONOS admin

${join("\n", formatlist("- `%s`", [for u in var.admin : u.email]))}

EOF
}
