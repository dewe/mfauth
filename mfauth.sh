#!/bin/bash

# op cli - https://support.1password.com/command-line/
# awsmfa util - https://pypi.org/project/awsmfa/
# aws cli - https://aws.amazon.com/cli/

set -e

OP_SUBDOMAIN=${OP_SUBDOMAIN:-"1password-subdomain"}
OP_ITEM_NAME=${OP_ITEM_NAME:-"My 1password item"}

main() {
    verify_dependency op
    verify_dependency awsmfa
    verify_dependency aws

    mfa=$(get_mfa "$OP_SUBDOMAIN" "$OP_ITEM_NAME")
    awsmfa --token-code $mfa 
}

get_mfa() {
    op signin "$1" --output=raw | op get totp "$2"
}

verify_dependency() {
    if ! is_installed $1; then
        abort "I require $1 but it's not installed"
    fi
}

is_installed() {
    command -v $1 >/dev/null 2>&1
}

abort() {
    echo >&2 ABORT: $*
    exit 1
}

main