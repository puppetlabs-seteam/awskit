#!/bin/sh

# purges all nodes with 'hops' in the name.

nodes=$(puppet cert list --all|grep hops|cut -d \" -f 2)
if [ "$PT_force" == "true" ] ; then
  puppet node purge $nodes
else
  echo "Nodes that would be purged:\n${nodes}"
fi