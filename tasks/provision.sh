#!/bin/bash

# Puppet Task Name: provision
#

usage() {

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

if [ "$(whoami)" == "root" ]; then
   echo "Please run this as a non-root user."
   exit -3
fi

# set default values of user and FACTER_aws_region
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

# PT_count=0

# Second argument (or $PT_count) is the number of servers to deploy
if [ ! -z ${2+x} ]; then PT_count=$2; fi
if [ ! -z ${PT_count+x} ]; then
  if ! [[ "$PT_count" =~ ^[0-9]+$ ]] ; then usage; fi
fi

# support task noop mode
if [ ! -z ${_noop+x} ]; then echo "Noop mode requested"; noop="--noop"; fi
if [ ! -z ${_debug+x} ]; then echo "Debug mode requested"; debug="--debug"; fi

# Validate type
# Reset count to 1 if more than 1 instance of the type is not supported
case $PT_type in
  master) PT_count=1 ;;
  linux_node) ;;
  linux_role) ;;
  windows_node) ;;
  artifactory) ;;
  discovery) PT_count=1 ;;
  discovery_nodes) ;;
  windc) PT_count=1 ;;
  wsus) PT_count=1 ;;
  cd4pe) PT_count=1 ;;
  bolt_workshop_master) ;;
  bolt_workshop_targets) ;;
  *) 
    echo "unknown type $PT_type specified."
    usage 
    ;;
esac

class="awskit::create_$PT_type"

if [ ! -z ${PT_count+x} ]; then
  puppet_params="count => ${PT_count},"
fi
if [ ! -z ${PT_role+x} ]; then
  puppet_params="${puppet_params} role => ${PT_role},"
fi

read -r -d '' manifest <<EOM
class { $class:
  ${puppet_params}
}
EOM

echo "applying manifest:"
echo "$manifest"
TASKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$manifest" | puppet apply --modulepath "${TASKDIR}/../..:$(puppet config print basemodulepath)" $noop $debug
