#!/bin/sh

# purges all nodes with 'hops' in the name.
# FIXME: completely untested
# FIXME: the puppetmaster needs to be excluded from the purge

nodes=$(puppet cert list --all|grep ${PT_pattern} | grep -v master |cut -d \" -f 2)
if [ "$PT_force" == "true" ] ; then
  puppet node purge $nodes
else
  echo "Nodes that would be purged:"
  echo $nodes
fi