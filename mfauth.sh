#!/bin/bash

# Examples:
# mfauth "My 1password item" 
# mfauth "My 1password item" "arn:aws:iam::123456789012:role/MyFunkyRole"

set -e

# get arguments, or default values from environment variables
OP_ITEM_NAME=${1:-$OP_ITEM_NAME}
AWS_ROLE_ARN=${2:-$AWS_ROLE_ARN}

main() {
    verify_dependency op
    verify_dependency awsmfa
    verify_dependency aws

    ensure_var "$OP_ITEM_NAME" "Missing 1Password item name as first argument or \$OP_ITEM_NAME"
    ensure_var "$OP_SUBDOMAIN" "Missing 1Password subdomain as \$OP_SUBDOMAIN"

    duration=$(get_duration_arg)
    mfa=$(get_mfa "$OP_SUBDOMAIN" "$OP_ITEM_NAME")
    awsmfa $duration --token-code $mfa "$AWS_ROLE_ARN"
}

get_mfa() {
    op signin "$1" --output=raw | op get totp "$2"
}

get_duration_arg() {
    if [ -n "$AWS_ROLE_ARN" ]; then
        echo -d 3600
    fi
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