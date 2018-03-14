# devhops::create_discovery
#
# This class creates an instance in AWS for Puppet Discovery to be installed on
#
# @summary Installs AWS instance for Puppet Discovery installation
#
# @example
#   include devhops::create_discovery
class devhops::create_discovery (
  $instance_type,
  $centos_user_data,
  $instance_name = 'discohops',
) {

  include devhops

  $discovery_ami = $devhops::discovery_ami

  Ec2_instance {
    instance_type     => $instance_type,
    region            => $devhops::region,
    availability_zone => $devhops::availability_zone,
    subnet            => $devhops::subnet,
    security_groups   => ['devhops-discovery'],
    key_name          => $devhops::key_name,
    tags              => $devhops::tags,
    require           => Ec2_securitygroup['devhops-discovery'],
  }

  ec2_securitygroup { 'devhops-discovery':
    ensure      => 'present',
    region      => $devhops::region,
    vpc         => $devhops::vpc,
    description => 'ssh and http(s) ingress for DevHops discovery',
    ingress     => [
      { protocol => 'tcp', port => 22,   cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 8080, cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 8443, cidr => '0.0.0.0/0', },
      { protocol => 'icmp',              cidr => '0.0.0.0/0', },
    ],
  }

  ec2_instance { "${instance_name}-1":
    ensure    => running,
    image_id  => $discovery_ami,
    user_data => inline_epp($centos_user_data),
  }
}
