# This file contains common terragrunt configuration included by every terragrunt module in the meshcloud foundations.

# Support plan file collection when running in CI, e.g. via GitHub Actions.
terraform {
  extra_arguments "plan" {
    commands = ["plan"]
    arguments = [
      "-out=plan.tfplan",
    ]
  }

  after_hook "preserve_plan" {
    if           = get_env("CI", "false") == "true"
    commands     = ["plan"]
    run_on_error = true
    execute = [
      "bash",
      "-c",
      # note: this script is very sensitive to line breaks, do not edit the grep command without testing it!!
      <<EOF
        output=$(tofu show -no-color plan.tfplan)

        if ! echo "$output" | grep -q "OpenTofu has compared your real infrastructure against your configuration and
        found no differences, so no changes are needed."; then

          PLAN_FILE="${get_repo_root()}/foundations/${path_relative_to_include()}/plan.tfplan";
          echo "Plan has changes, preserving plan file to $PLAN_FILE";

          cp plan.tfplan "$PLAN_FILE";

          echo "### :warning: Plan has changes for ${path_relative_to_include()}" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "\`\`\`" >> $GITHUB_STEP_SUMMARY
          echo "$output" >> $GITHUB_STEP_SUMMARY
          echo "\`\`\`" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "View full details including colored output in the [build job logs](https://github.com/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID)" >> $GITHUB_STEP_SUMMARY

        else
          echo "Plan has no changes, no plan file to preserve."
        fi
      EOF
    ]
  }
}