#!/bin/bash

# Puppet Task Name: provision
#

function usage() {

cat << EOU

Usage: 

[_noop="yes"] $0 <type> [<count>]

Usage in task mode:

[_noop="yes"] [PT_count=<count>] PT_type=<type> $0

- type should be one of: ['master', 'linux_node', 'windows_node', 'discovery', 'windc', 'wsus', 'cd4pe']
- count should be an integer, default: value configured in hiera

Examples:

Provision a master:

$0 master

Provision 7 windows nodes in noop mode, used as a task:

_noop="yes" PT_count=7 PT_type=windows_node $0

EOU

exit -2
}

# if [ "$(whoami)" == "root" ]; then
#    echo "Please run this as a non-root user."
#    exit -3
# fi

# set default values of FACTER_USER and FACTER_aws_region
if [ -z ${FACTER_user+x} ]; then FACTER_user=$USER; fi
if [ -z ${FACTER_aws_region+x} ]; then FACTER_aws_region=$AWS_REGION; fi

# check for AWS configuration
# if [ -z "$AWS_ACCESS_KEY_ID" ] && [ ! -d ~/.aws ]; then # try to read them from the instance metadata
#   echo "No AWS credentials found, trying to get EC2 IAM credentials..."
#   declare creds_url="http://169.254.169.254/latest/meta-data/iam/security-credentials/FullAccess"
#   declare ec2_creds
#   if ! ec2_creds=$(curl -s "$creds_url"); then
#     echo "EC2 IAM credentials not found, exiting..."
#     exit -4
#   fi
#   declare AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
#   AWS_ACCESS_KEY_ID=$(echo "$ec2_creds" | jq -r .AccessKeyId)
#   AWS_SECRET_ACCESS_KEY=$(echo "$ec2_creds" | jq -r .SecretAccessKey)
#   AWS_SESSION_TOKEN=$(echo "$ec2_creds" | jq -r .Token)
#   export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
# fi

# shellcheck disable=SC2154
if [ ! -z "$PT_region" ]; then
  echo "Region overruled by task parameter: $PT_region"
  export AWS_REGION=${PT_region//_/-} # hack: can't use hyphens in metadata
  export AWS_DEFAULT_REGION=$AWS_REGION
  export FACTER_aws_region=$AWS_REGION
  export FACTER_user='plive2018' # FIXME hack
else
  echo "found region: $FACTER_aws_region"
  echo "found user: $FACTER_user"
fi

# First argument (or $PT_type) is the type of server to deploy
if [ ! -z ${1+x} ]; then 
  PT_type=$1
else 
  if [ -z ${PT_type+x} ]; then 
    usage 
  fi
fi

PT_count=1

# set AWS variables from parameters


# Second argument (or $PT_count) is the number of servers to deploy
if [ ! -z ${2+x} ]; then PT_count=$2; fi
if ! [[ "$PT_count" =~ ^[0-9]+$ ]] ; then usage; fi

# support task noop mode
# shellcheck disable=SC2154
if [ ! -z ${_noop+x} ]; then echo "Noop mode requested"; noop="--noop"; fi
# shellcheck disable=SC2154
if [ ! -z ${_debug+x} ]; then echo "Debug mode requested"; debug="--debug"; fi

# Validate type
# Reset count to 1 if more than 1 instance of the type is not supported
case $PT_type in
  master) PT_count=1 ;;
  linux_node) ;;
  linux_role) ;;
  windows_node) ;;
  discovery) PT_count=1 ;;
  windc) PT_count=1 ;;
  wsus) PT_count=1 ;;
  cd4pe) PT_count=1 ;;
  *) 
    echo "unknown type $PT_type specified."
    usage 
    ;;
esac

class="awskit::create_$PT_type"

puppet_params="count => ${PT_count},"
# shellcheck disable=SC2154
if [ ! -z ${PT_role+x} ]; then
  puppet_params="${puppet_params} role => ${PT_role},"
fi

# shellcheck disable=SC2154
if [ ! -z ${PT_name+x} ]; then
  puppet_params="${puppet_params} instance_name => ${PT_name},"
fi

read -r -d '' manifest <<EOM
class { $class:
  ${puppet_params}
}
EOM

echo "applying manifest:"
echo "$manifest"
# TASKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# echo "$manifest" | puppet apply --modulepath "${TASKDIR}/../..:$(puppet config print basemodulepath)" $noop $debug
echo "$manifest" | puppet apply $noop $debug
