#!/bin/bash

# Puppet Task Name: provision
#

usage() {

cat << EOU

Usage: 

[_noop="yes"] $0 <type> [<count>]

Usage in task mode:

[_noop="yes"] [PT_count=<count>] PT_type=<type> $0

- type should be one of: ['master', 'linux_node', 'windows_node', 'discovery', 'windc']
- count should be an integer, default: value configured in hiera

Examples:

Provision a master:

$0 master

Provision 7 windows nodes in noop mode, used as a task:

_noop="yes" PT_count=7 PT_type=windows_node $0

EOU

exit -2
}

# set default values of FACTER_USER and FACTER_aws_region
if [ -z ${FACTER_user+x} ]; then FACTER_user=$USER; fi
if [ -z ${FACTER_aws_region+x} ]; then FACTER_aws_region=$AWS_REGION; fi

echo "found region: $FACTER_aws_region"
echo "found user: $FACTER_user"

# First argument (or $PT_type) is the type of server to deploy
if [ ! -z ${1+x} ]; then 
  PT_type=$1
else 
  if [ -z ${PT_type+x} ]; then 
    usage 
  fi
fi

# Second argument (or $PT_count) is the number of servers to deploy
if [ ! -z ${2+x} ]; then PT_count=$2; fi
if ! [[ "$PT_count" =~ ^[0-9]+$ ]] ; then usage; fi

# support task noop mode
if [ ! -z ${_noop+x} ]; then echo "Noop mode requested"; noop="--noop"; fi

# Validate type
# Reset count to 1 if more than 1 instance of the type is not supported
case $PT_type in
  master) PT_count=1;;
  linux_node) ;;
  windows_node) ;;
  discovery) PT_count=1 ;;
  windc) PT_count=1 ;;
  *) 
    echo "unknown type $PT_type specified."
    usage 
    ;;
esac

class="devhops::create_$PT_type"

puppet_params=""
if [[ ! -z ${PT_count+x} && ${PT_count} -gt 1 ]]; then
  puppet_params="count => ${PT_count},"
fi
read -r -d '' manifest <<EOM
class { $class:
  ${puppet_params}
}
EOM

echo "applying manifest:"
echo "$manifest"

echo "$manifest" | puppet apply --modulepath .. $noop
