# aws-utils

Stuff for AWS

## mfauth

Script for signing in to [AWS CLI](https://aws.amazon.com/cli/) with multi-factor auth with 1Password.

Dependencies:

* `op`: https://support.1password.com/command-line/
* `aws`: https://aws.amazon.com/cli/
* `awsmfa`: https://pypi.org/project/awsmfa/

The script assumes default setup for `awsmfa`, using the default aws profile. See `awsmfa` docs, section "Getting started".

Configure environment variables:

* `OP_SUBDOMAIN` - 1password subdomain for authentication, see [1password CLI docs](https://support.1password.com/command-line/#sign-in-or-out).
* `OP_ITEM_NAME` - optional: the 1password item that has an MFA code, specified as either an [item name or uuid](https://support.1password.com/command-line/#appendix-specifying-objects).

For convenience, the 1Password item name or uuid can be provided as an argument. This will override the environment variable setting.

```bash
mfauth "My 1password login item name"
```
