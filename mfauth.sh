#!/bin/bash

# op cli - https://support.1password.com/command-line/
# awsmfa util - https://pypi.org/project/awsmfa/
# aws cli - https://aws.amazon.com/cli/

set -e

# get first argument or environment variable
OP_ITEM_NAME=${1:-$OP_ITEM_NAME}

main() {
    verify_dependency op
    verify_dependency awsmfa
    verify_dependency aws

    ensure_var "$OP_ITEM_NAME" "Missing 1Password item name as first argument or \$OP_ITEM_NAME"
    ensure_var "$OP_SUBDOMAIN" "Missing 1Password subdomain as \$OP_SUBDOMAIN"

    mfa=$(get_mfa "$OP_SUBDOMAIN" "$OP_ITEM_NAME")
    awsmfa --token-code $mfa 
}

get_mfa() {
    op signin "$1" --output=raw | op get totp "$2"
}

# if $1 is zero-length string, abort with message $2 
ensure_var() {
    if [ -z "$1" ]; then
        abort "$2"
    fi
}

# check that executable $1 is installed
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