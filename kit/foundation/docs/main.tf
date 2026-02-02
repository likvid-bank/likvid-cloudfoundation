locals {
  terragrunt_modules = toset([
    for x in fileset(var.foundation_dir, "**/terragrunt.hcl") : trimsuffix(x, "/terragrunt.hcl")
    if(
      !strcontains(x, ".terragrunt-cache") && # this might not be required, check
      !strcontains(x, "/tenants/") &&         # we don't document individual tenants, though maybe we should?
      !strcontains(x, "/test/")               # we don't document tests
    )
  ])

  terragrunt_to_kit_modules = {
    for key in local.terragrunt_modules :
    key => startswith(key, "platforms/")
    ? trimprefix(key, "platforms/") # platform module ids are relative to the platforms directory
    : "foundation/${key}"           # foundation modules are prefixed with foundation
  }

  terragrunt_modules_to_backend = flatten([
    for x in var.module_docs : [
      for y in local.terragrunt_modules : {
        module     = y
        prefix     = x.prefix
        key_prefix = x.key_prefix != null ? x.key_prefix : ""
        backend    = x.backend
        config     = x.config

      } if startswith(y, x.prefix)
    ]
  ])

  remote_state_modules = {
    for x in local.terragrunt_modules_to_backend : x.module => {
      backend = x.backend
      config = merge(
        x.config,
        # configure the convention used to locate the module's specific tfstate file in the backend
        # sometimes the key is prefixed with the platform module id, but often it's left out (in case of just a single platform stored in a state backend for example)
        x.backend == "gcs"
        ? { prefix = "${x.key_prefix}${trimprefix(x.module, "${x.prefix}/")}" }
        : { key = "${x.key_prefix}${trimprefix(x.module, "${x.prefix}/")}.tfstate" }
      )
    }
  }
}

data "terraform_remote_state" "docs" {
  for_each = local.remote_state_modules

  backend = each.value.backend
  config  = each.value.config
}

locals {
  kit_dir        = "${var.repo_dir}/kit"
  compliance_dir = "${var.repo_dir}/compliance"
}

locals {

  platform_readmes = fileset("${var.foundation_dir}/platforms", "*/README.md")

  kit_readmes = toset([
    for x in fileset(local.kit_dir, "**/README.md") : x
    if(
      !strcontains(x, ".terraform") &&
      !strcontains(x, ".terragrunt-cache")
    )
  ])

  parsed_kit_modules = { for x in local.kit_readmes :
    trimsuffix(x, "/README.md") => try(yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file("${local.kit_dir}/${x}"))[0]), null)
  }

  compliance_readmes = toset([
    for x in fileset(local.compliance_dir, "**/*.md") : x
  ])

  parsed_compliance_controls = { for x in local.compliance_readmes :
    trimsuffix(x, ".md") => try(yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file("${local.compliance_dir}/${x}"))[0]), null)
  }

  kit_modules = {
    for key, value in local.parsed_kit_modules :
    key => value

    if value != null
  }

  kit_module_compliance_md = {
    for key, value in local.kit_modules :
    key => join(
      "\n",
      compact([for s in try(value.compliance, []) : try(
        "- [${local.parsed_compliance_controls[s.control].name}](/compliance/${s.control}.md): ${trimspace(s.statement)}",
        "<!-- error locating compliance control ${s.control} -->"
      )])
    )
  }
}

resource "terraform_data" "copy_template" {
  triggers_replace = {
    output_dir         = var.output_dir
    template_dir       = var.template_dir
    template_dir_files = join(" ", fileset(var.template_dir, "**/*")) # since we use symbolic links, we don't care for file content
  }

  provisioner "local-exec" {
    when = create
    # copy files as symbolic links, this means we can change them in the source dir and live reload will work!
    command = "mkdir -p ${self.triggers_replace.output_dir} && cp -a -R -L ${self.triggers_replace.template_dir}/* ${self.triggers_replace.output_dir}"
  }

  provisioner "local-exec" {
    when = destroy
    # remove symbolic links
    command = "cd ${self.triggers_replace.output_dir} && rm -f ${self.triggers_replace.template_dir_files}"
  }
}

resource "terraform_data" "copy_compliance" {
  triggers_replace = {
    output_dir           = var.output_dir
    compliance_dir       = local.compliance_dir
    compliance_dir_files = join(" ", fileset(local.compliance_dir, "**/*")) # since we use symbolic links, we don't care for file content
  }

  provisioner "local-exec" {
    when = create
    # copy files as symbolic links, this means we can change them in the source dir and live reload will work!
    command = "mkdir -p ${self.triggers_replace.output_dir}/docs/compliance && cp -a -R -L ${self.triggers_replace.compliance_dir}/* ${self.triggers_replace.output_dir}/docs/compliance"
  }

  provisioner "local-exec" {
    when = destroy
    # remove symbolic links
    command = "cd ${self.triggers_replace.output_dir}/docs/compliance && rm -f ${self.triggers_replace.compliance_dir_files}"
  }
}

resource "local_file" "module_docs" {
  depends_on = [terraform_data.copy_template]
  for_each   = local.terragrunt_modules

  filename = "${var.output_dir}/docs/${each.key}.md"
  content = join(
    "\n\n",
    compact([
      # documentation_md
      try(
        data.terraform_remote_state.docs[each.key].outputs.documentation_md,
        "*no `documentation_md` output provided*"
      ),
      # by convention, we expect that a platform module uses the same kit module name so we use that to lookup compliance statements
      "## Compliance Statements",
      coalesce(
        try(local.kit_module_compliance_md[local.terragrunt_to_kit_modules[each.key]], null),
        "*no compliance statements provided*"
      )
    ])
  )
}

# todo: not sure we want those
resource "local_file" "platform_readmes" {
  depends_on = [terraform_data.copy_template]
  for_each   = local.platform_readmes

  filename = "${var.output_dir}/docs/platforms/${each.key}"
  content  = file("${var.foundation_dir}/platforms/${each.key}")
}

locals {
  guides = try(data.terraform_remote_state.docs["meshstack"].outputs.documentation_guides_md, {})
}

resource "local_file" "meshstack_guides" {
  depends_on = [terraform_data.copy_template]
  for_each   = local.guides

  filename = "${var.output_dir}/docs/meshstack/guides/${each.key}.md"
  content  = each.value
}
