---
# WORKAROUND as SAP BTP is not supported
aws:
  accountId: "xxx"
  accountAccessRole: "xxx"
cli:
  aws:
    AWS_PROFILE: xxx
    AWS_REGION: xxx
---

# SAP BTP

In SAP BTP Cloud, a "contract" refers to the agreement or subscription plan that you have with them for using their cloud services. It outlines the terms, conditions, and pricing for the resources and features you're entitled to use within the SAP BTP cloud platform.

We currently have an SAP BTP contract no. 0000000, where we plan to:

- Test meshStack's custom platform functionality and have SAP BTP as a platform

## Admin Accounts

Root account is stored in Bitwarden under `Infrastructure/Cloud Master Accounts`. Note that it also includes a TOTP, use it as a verification code when logging in.

We also have a manually created admin user to be used in automation with email `apiuser@meshcloud.io` and enabled
`Administrator` flag.

## Billing Account

TBD
