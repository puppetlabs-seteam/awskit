#!/bin/sh -x

# Puppet Task Name: provision
#

usage() {

cat << EOU

Usage: 

[_noop="yes"] [PT_count=<count>] PT_type=<type> $0

or, as a shortcut: 

[_noop="yes"] $0 <type> [<count>]

- type should be one of: ['master', 'linux_node', 'windows_node', 'discovery', 'windc']
- count should be an integer, default: value configured in hiera

Examples:

Provision a master:

PT_type=master $0
or
$0 master
h
Provision 7 windows nodes in noop mode:

_noop="yes" PT_count=7 PT_type=windows_node $0
or
_noop="yes" $0 windows_node 7

EOU

exit -2
}

if [ -z ${FACTER_user+x} ]; then FACTER_user=$USER; fi
if [ -z ${FACTER_aws_region+x} ]; then FACTER_aws_region=$AWS_REGION; fi

echo found region: $FACTER_aws_region
echo found user: $FACTER_user

if [ ! -z ${1+x} ]; then 
  PT_type=$1
else 
  if [ -z ${PT_type+x} ]; then 
    usage 
  fi
fi
if [ ! -z ${2+x} ]; then PT_count=$2; fi
if [ ! -z ${_noop+x} ]; then echo "Noop mode requested"; noop="--noop"; fi

case $PT_type in
  master)  ;;
  linux_node) ;;
  windows_node) ;;
  discovery) ;;
  windc) ;;
  *) 
    usage 
    ;;
esac

[[ $PT_count =~ "^[0-9]+$" ]] || { usage }

class="devhops::create_$PT_type"

puppet_params=""
if [ ! -z ${PT_count+x} ]; then
  puppet_params="count => ${PT_count},"
fi
read -r -d '' manifest <<EOM
class { $class:
  ${puppet_params}
}
EOM

echo "applying manifest:"
echo "$manifest"

echo $manifest | puppet apply --modulepath .. $noop