# awskit::create_discovery_nodes
#
# This class creates 9 instances in AWS for Puppet Discovery to forage
#
# @summary Deploys 9 AWS instances for Puppet Discovery to forage
#
# @example
#   include awskit::create_discovery_nodes
class awskit::create_discovery_nodes (
  $instance_type,
  $count         = 9,
  $instance_name = 'awskit-disconode',
) {

  include awskit

  ec2_securitygroup { "${facts['user']}-awskit-disco":
    ensure      => 'present',
    region      => $awskit::region,
    vpc         => $awskit::vpc,
    description => 'ssh and http(s) ingress for awskit discovery',
    ingress     => [
      { protocol => 'tcp', port => 22,   cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 8080, cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 8443, cidr => '0.0.0.0/0', },
      { protocol => 'icmp',              cidr => '0.0.0.0/0', },
    ],
  }

  range(1,$count).each | $i | {
    awskit::create_host { "${instance_name}-${i}":
      ami                   => $awskit::centos_ami,
      instance_type         => $instance_type,
      user_data_template    => 'awskit/discovery_node_userdata.epp',
      security_groups       => ["${facts['user']}-awskit-disco"],
      delete_on_termination => true
    }
  }
}
