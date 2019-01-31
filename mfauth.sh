#!/bin/bash

set -e

OP_SUBDOMAIN=""
OP_ITEM=""
AWS_ROLE_ARN=""
AWS_MFA_DURATION=3600
ROLE_SESSION_NAME="$(whoami)@$(hostname)"

main() {
    parse_args "$@"

    verify_dependency op
    verify_dependency awsmfa
    verify_dependency aws

    ensure_var "$OP_SUBDOMAIN" "Missing value for \$SUBDOMAIN"
    ensure_var "$OP_ITEM" "Missing value for \$OP_ITEM"

    assume_role=$(get_role_session)
    mfa=$(get_mfa "$OP_SUBDOMAIN" "$OP_ITEM")
    
    echo -n "Authenticating... "
    awsmfa --token-code $mfa $assume_role
}

parse_args() {
    args=( )

    # get named options
    while (( "$#" )); do
    case "$1" in
    -h|--help)
        echo; echo "Help:"
        usage
        exit
        ;;
    -d|--duration)
        AWS_MFA_DURATION=$2
        shift 2
        ;;
    -r|--role-to-assume)
        AWS_ROLE_ARN=$2
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
    OP_SUBDOMAIN=$1
    OP_ITEM=$2
}

get_mfa() {
    op signin "$1" --output=raw | op get totp "$2"
}

get_role_session() {
    if [ -n "$AWS_ROLE_ARN" ]; then
        echo --role-session-name $ROLE_SESSION_NAME --duration $AWS_MFA_DURATION $AWS_ROLE_ARN
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
      echo "Usage: mfauth [SUBDOMAIN] [OP_ITEM] -r [AWS-ROLE] -d [DURATION]"
      echo
      echo "positional arguments:"
      echo "  SUBDOMAIN     The name of the subdomain for your 1password account"
      echo "                to be used when logging in with 1password."
      echo "  OP_ITEM       Name or uuid of the 1Password item that holds the"
      echo "                two factor authentication code."
      echo
      echo "optional arguments:"
      echo "  -d DURATION, --duration DURATION"
      echo "                The number of seconds for the temporary credentials"
      echo "                to be valid for. Max 1 hour when assuming a role."
      echo "                (Default value: 3600)"
      echo "  -r AWS_ROLE, --role-to-assume AWS_ROLE"
      echo "                Full ARN of the AWS IAM role you wish to assume." 
      echo "                (Default value: None)"
      echo "  -h, --help"
      echo "                Show this help text."
      echo 
}

main "$@"; exit