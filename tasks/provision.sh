#!/bin/sh

# Puppet Task Name: provision
#

if [ -z ${FACTER_user+x} ]; then FACTER_user=$USER; fi
if [ -z ${FACTER_aws_region+x} ]; then FACTER_aws_region=$AWS_REGION; fi

echo found region: $FACTER_aws_region
echo found user: $FACTER_user

if [ ! -z ${1+x} ]; then 
  PT_type=$1
else 
  if [ -z ${PT_type+x} ]; then 
    echo "Please specify the type to provision"; exit -1; 
  fi
fi

if [ ! -z ${_noop+x} ]; then echo "Noop mode requested"; noop="--noop"; fi

case $PT_type in
  master)  ;;
  linux_node) ;;
  windows_node) ;;
  discovery) ;;
  windc) ;;
  *)
    echo "Type should be one of 'master', 'linux_node', 'windows_node', 'discovery', 'windc'"
    exit -2
    ;;
esac


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

echo $manifest | puppet apply --modulepath .. --noop