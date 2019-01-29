#!/bin/bash

## TODO:
# make assume role optional again
# add help option

set -e

# variables and defaults
SUBDOMAIN=""
OP_ITEM_NAME=""
AWS_ROLE_ARN=$AWS_ROLE_ARN
AWS_MFA_DURATION=${AWS_MFA_DURATION:-3600}

main() {
    parse_args "$@"

    verify_dependency op
    verify_dependency awsmfa
    verify_dependency aws

    ensure_var "$SUBDOMAIN" "Missing 1Password subdomain as environment variable \$SUBDOMAIN"
    ensure_var "$OP_ITEM_NAME" "Missing value for \$OP_ITEM_NAME"
    ensure_var "$AWS_ROLE_ARN" "Missing value for \$AWS_ROLE_ARN"

    assume_role=$(get_role_and_duration)
    mfa=$(get_mfa "$SUBDOMAIN" "$OP_ITEM_NAME")
    
    awsmfa --token-code $mfa $assume_role
}

parse_args() {
    args=( )

    # get named options
    while (( "$#" )); do
    case "$1" in
    -d|--duration)
        AWS_MFA_DURATION=$2
        shift 2
        ;;
    --) # end argument parsing
        shift
        break
        ;;
    -*|--*=) # unsupported flags
        echo
        echo Error: Unsupported argument $1 >&2
        usage
        exit 1
        ;;
    *) # preserve positional arguments
        args+=( "$1" )
        shift
        ;;
    esac
    done

    # get remaining positional args
    set -- "${args[@]}"
    SUBDOMAIN=$1
    OP_ITEM_NAME=$2
    AWS_ROLE_ARN=${3:-$AWS_ROLE_ARN}
}

get_mfa() {
    op signin "$1" --output=raw | op get totp "$2"
}

get_role_and_duration() {
    if [ -n "$AWS_ROLE_ARN" ]; then
        echo --duration $AWS_MFA_DURATION $AWS_ROLE_ARN
    fi
}

# if $1 is zero-length string, abort with message $2 
ensure_var() {
    if [ -z "$1" ]; then
        echo >&2 Error: $2
        usage
        exit 1
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
    echo >&2 Error: $*
    exit 1
}

usage() {
      echo 
      echo "Usage: mfauth [SUBDOMAIN] [OP_ITEM_NAME] [AWS_ROLE_ARN] -d [AWS_MFA_DURATION]"
      echo
      echo "positional arguments:"
      echo "  SUBDOMAIN        The name of the subdomain for your 1password account"
      echo "                   to be used when logging in with 1password."
      echo "  OP_ITEM_NAME     Name or uuid of the 1Password item that holds the"
      echo "                   two factor authentication code."
      echo "  AWS_ROLE_ARN     ARN for the AWS IAM role to assume. Default value"
      echo "                   from AWS_ROLE_ARN environment variable, if set."
      echo
      echo "optional arguments:"
      echo "  -d DURATION, --duration DURATION"
      echo "                   The number of seconds for the temporary credentials"
      echo "                   to be valid for. Default 1 hour. Max 1 hour when"
      echo "                   assuming a role."
      echo ""
      echo ""
      echo ""
      echo ""
      echo 
}

main "$@"; exit