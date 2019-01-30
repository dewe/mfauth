# aws-utils

Stuff for AWS

## mfauth

Script for signing in to [AWS CLI](https://aws.amazon.com/cli/) with multi-factor authenitcation, using 1Password for generationg the MFA code.

### Dependencies

* `op`: [https://support.1password.com/command-line](https://support.1password.com/command-line/)
* `aws`: [https://aws.amazon.com/cli](https://aws.amazon.com/cli/)
* `awsmfa`: [https://pypi.org/project/awsmfa](https://pypi.org/project/awsmfa/)

### Setup `op`

See [1Password command-line tool: Getting started](https://support.1password.com/command-line-getting-started/)

### Setup `awsmfa`

The script assumes that `awsmfa` has the default setup as described in [awsmfa docs, getting started](https://github.com/dcoker/awsmfa#getting-started).

### Usage

```bash
mfauth [SUBDOMAIN] [OP_ITEM] -r [AWS-ROLE] -d [DURATION]
```

* `SUBDOMAIN`: The 1password account used for logging in with `op [subdomain]`
* `OP_ITEM`: Name of the 1password item that has the two factor code configured. Copy and paste from 1password GUI.
* `AWS_ROLE`: (Optional) Full ARN of the AWS IAM Role to assume. If empty, you will be logged in with the default identity, but no role.
* `DURATION`: (Optional) length of AWS token session, in seconds.