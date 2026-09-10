# Per-run identifiers for a smoke test's `test_context` — see the `hub` skill. `run_cmd` is cached
# per unit, so every e2e unit in one `run --all` gets its own pair.
#
# Kept out of `smoke.hcl` because that file is the smoke-test workflow's queue marker: an e2e unit
# that still depends on its deployment's state must be able to share these without joining it.

locals {
  name_suffix = run_cmd("--terragrunt-quiet", "date", "-u", "+%Y%m%d%H%M%S")

  # "st" + YYMMDDhhmm + 3 random chars, the shape every hub e2e test composes its names from.
  run_id = "st${run_cmd("--terragrunt-quiet", "date", "-u", "+%y%m%d%H%M")}${run_cmd("--terragrunt-quiet", "sh", "-c", "LC_ALL=C tr -dc a-z0-9 </dev/urandom | head -c 3")}"
}
