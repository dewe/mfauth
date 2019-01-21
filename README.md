# aws-utils

Stuff for AWS

## mfauth

Script for signing in to [AWS CLI](https://aws.amazon.com/cli/) with multi-factor auth with 1Password.

Dependencies:

* `op`: https://support.1password.com/command-line/
* `awsmfa`: https://pypi.org/project/awsmfa/

The script assumes default setup for `awsmfa`, using the default aws profile. See `awsmfa` docs, section "Getting started".

Configure environment variables:

* `OP_SUBDOMAIN` - one password subdomain for authentication, see 1password CLI docs.
* `OP_ITEM_NAME` - the name of the 1password item with mfa code set up.
