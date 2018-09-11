# awskit::create_discovery_nodes
#
# This class creates 10 instances in AWS for Puppet Discovery to fourage
#
# @summary Deploys 10 AWS instances for Puppet Discovery to fourage
#
# @example
#   include awskit::create_discovery_nodes
class awskit::create_discovery_nodes (
  $instance_type,
  $user_data,
  $count         = 10,
  $instance_name = 'awskit-disconode',
) {

  include awskit

  range(1,$count).each | $i | {
    awskit::create_host { "${instance_name}-${i}":
      ami             => $awskit::centos_ami,
      instance_type   => $instance_type,
      user_data       => $user_data,
      security_groups => [$awskit::disco_sc_name],
    }
  }
}
