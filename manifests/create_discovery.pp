# awskit::create_discovery
#
# This class creates an instance in AWS for Puppet Discovery to be installed on
#
# @summary Installs AWS instance for Puppet Discovery installation
#
# @example
#   include awskit::create_discovery
class awskit::create_discovery (
  $instance_type,
  $user_data,
  $count         = 1,
  $instance_name = 'awskit-disco',
) {

  include awskit

  $ami = $awskit::discovery_ami

  ec2_securitygroup { 'awskit-discovery':
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

  awskit::create_host { $instance_name:
    ami             => $ami,
    instance_type   => $instance_type,
    user_data       => $user_data,
    security_groups => ['awskit-discovery'],
    require         => Ec2_securitygroup['awskit-discovery'],
  }

}
