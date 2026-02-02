# Likvid Bank Cloud Foundation

This is the cloud foundation infrastructure as code repository defining the internal developer platform of Likvid Bank as IaC
using terraform and terragrunt.

This repository is maintained by the cloud foundation team. To learn more about our cloud foundation, please
review our documentation at https://likvid-bank.github.io/likvid-cloudfoundation/

*The documentation is generated from this repository and deployed with GitHub pages.*

## Development Instructions

### Development Environment

This repo includes a nix flake devShell with all required dependencies.
You can open a devShell using `nix develop`.

### Authenticating to Cloud Platforms

Ensure you have run `az login` and `gcloud auth login` into the right cloud tenant/GCP organization.
For `aws`:

```shellsession
aws configure sso-session
SSO session name: likvid-prod
SSO start URL [None]: https://meshcloud-dev.awsapps.com/start/#
SSO region [None]: eu-central-1
SSO registration scopes [sso:account:access]:

Completed configuring SSO session: likvid-prod
Run the following to login and refresh access token for this session:

aws sso login --sso-session likvid-prod
```

Now you also need to create a profile that uses this sso session (note: the profile is just called likvid)

```shellsession
aws configure sso
SSO session name (Recommended): likvid-prod
There are 3 AWS accounts available to you.
Using the account ID 702461728527
There are 4 roles available to you.
Using the role name "likvid-foundation-platform-engin"
CLI default client Region [eu-central-1]:
CLI default output format [None]:
CLI profile name [likvid-foundation-platform-engin-702461728527]: likvid
```
