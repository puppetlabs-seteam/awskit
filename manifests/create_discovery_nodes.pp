# awskit::create_discovery_nodes
#
# This class creates 9 instances in AWS for Puppet Discovery to fourage
#
# @summary Deploys 9 AWS instances for Puppet Discovery to fourage
#
# @example
#   include awskit::create_discovery_nodes
class awskit::create_discovery_nodes (
  $instance_type,
  $user_data,
  $count         = 9,
  $instance_name = 'awskit-disconode',
) {

  include awskit

  ec2_securitygroup { $awskit::disco_sc_name:
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
      ami             => $awskit::centos_ami,
      instance_type   => $instance_type,
      user_data       => $user_data,
      security_groups => [$awskit::disco_sc_name],
    }
  }
}
