# This unit supersedes the `backplane/` unit next to it, which sourced the hub backplane submodule
# as its own root. The backplane is now a child of the module that also owns the building block
# definition, so one apply can swap the backplane's credentials and rewrite the definition that
# carries them.
#
# Terragrunt derives a state prefix from the unit path, so the old state has to be copied to this
# unit's prefix before the first plan — see the PR description for the command. These blocks then
# re-address its resources into the child module, so nothing is destroyed and recreated.
#
# Two resources have no destination: `google_service_account_key.backplane`, the static key the
# WIF migration replaces, and `google_project_iam_member.serviceusage_admin`, which the building
# block no longer needs. Both are meant to be destroyed, so neither gets a block here.

moved {
  from = google_service_account.backplane
  to   = module.budget_alert.module.backplane.google_service_account.backplane
}

moved {
  from = google_billing_account_iam_member.budget_admin
  to   = module.budget_alert.module.backplane.google_billing_account_iam_member.budget_admin
}

moved {
  from = google_billing_account_iam_member.billing_viewer
  to   = module.budget_alert.module.backplane.google_billing_account_iam_member.billing_viewer
}

moved {
  from = google_project_iam_member.notification_channel_admin
  to   = module.budget_alert.module.backplane.google_project_iam_member.notification_channel_admin
}

# The backplane module moves this on to `required["billingbudgets.googleapis.com"]` itself, so the
# two blocks chain.
moved {
  from = google_project_service.billingbudgets
  to   = module.budget_alert.module.backplane.google_project_service.billingbudgets
}
