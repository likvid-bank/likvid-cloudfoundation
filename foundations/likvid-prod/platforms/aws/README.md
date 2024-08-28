---
aws:
  accountId: "702461728527"
  accountAccessRole: "OrganizationAccountAccessRole"
cli:
  aws:
    AWS_PROFILE: likvid                # required
---

# likvid-prod

This AWS organization hosts meshcloud-dev and likvid-demo foundations.

In this AWS account our meshstack dev installation is running.

```text
Account Name: meshstack-dev
Root User Email: meshstack-dev@meshcloud.io
```

Password for this account can be found in pass in `dev/locations/aws/meshstack-dev`.

The infrastructure is deployed in `Frankfurt` AWS region. Remember to switch to that region to find the running infrastructure.

## Global Infrastructure

> TODO: this is no longer current since the docs have moved on to netlify?

This is also the account that hosts [docs.meshcloud.io](http://docs.meshcloud.io) and [docs.dev.meshcloud.io](http://docs.dev.meshcloud.io) buckets.

## AWS SSO

You can sign in to this platform with AWS SSO configured against our meshcloud-dev AAD https://meshcloud-dev.awsapps.com/start
