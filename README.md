# mfauth

Use 1Password for AWS MFA login in terminal.

Script for signing in to [AWS CLI](https://aws.amazon.com/cli/) with multi-factor authenitcation, using 1Password for generationg the MFA code.

## Dependencies

* `op`: https://support.1password.com/command-line
* `aws`: https://aws.amazon.com/cli
* `awsmfa`: https://github.com/dcoker/awsmfa

### Setup `op`

See [1Password command-line tool: Getting started](https://support.1password.com/command-line-getting-started/)

### Setup `awsmfa`

The script assumes that `awsmfa` has the default setup as described in [awsmfa docs, getting started](https://github.com/dcoker/awsmfa#getting-started).

## Usage

```bash
mfauth [SUBDOMAIN] [OP_ITEM] -r [AWS-ROLE] -d [DURATION]
```

* `SUBDOMAIN`: The 1password account used for logging in with `op [subdomain]`
* `OP_ITEM`: Name of the 1password item that has the two factor code configured. Copy and paste from 1password GUI.
* `AWS_ROLE`: (Optional) Full ARN of the AWS IAM Role to assume. If empty, you will be logged in with the default identity, but no role.
* `DURATION`: (Optional) length of AWS token session, in seconds.

## Optional timer in Mac OS Menu Bar

1. Get BitBar via https://getbitbar.com, or with Homebrew: `brew cask install bitbar`

    > **Note:** When starting BitBar for the first time, make sure to select an new empty folder as plugin folder. BitBar will try to run any file in the plugin folder, with curious results if there are any non-plugins in that folder. See https://github.com/matryer/bitbar#installing-plugins for reference.

2. Add [Countdown Timer plugin](https://getbitbar.com/plugins/Time/countdown_timer.1s.rb) to BitBar, and ensure you have execution rights for the plugin file.

3. Make the countdown plugin file available in the system PATH.

4. Test the script

    ```bash
    $ which countdown_timer.1s.rb
    /path/to/bitbar/plugins/countdown_timer.1s.rb

    $ countdown_timer.1s.rb 3600h
    $ countdown_timer.1s.rb
    00:59:55
    ```

Now the countdown timer will be set after a successful authentication, showing the remaining time in the menu bar.