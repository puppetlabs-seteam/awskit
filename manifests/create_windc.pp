# devhops::create_windc
#
# This class creates an instance in AWS for a Windows Domain Controller to be installed on
#
# @summary Installs AWS instance for Windows Domain Controller installation
#
# @example
#   include devhops::create_windc
class devhops::create_windc (
  $instance_type,
  $user_data,
  $instance_name = 'windchops-1',
) {

  include devhops

  $ami = $devhops::windc_ami

  Ec2_instance {
    instance_type     => $instance_type,
    region            => $devhops::region,
    availability_zone => $devhops::availability_zone,
    subnet            => $devhops::subnet,
    security_groups   => ['devhops-windc'],
    key_name          => $devhops::key_name,
    tags              => $devhops::tags,
    require           => Ec2_securitygroup['devhops-windc'],
  }

  ec2_securitygroup { 'devhops-windc':
    ensure      => 'present',
    region      => $devhops::region,
    vpc         => $devhops::vpc,
    description => 'RDP ingress for DevHops Windows DC',
    ingress     => [
      { protocol => 'tcp', port => 3389, cidr => '0.0.0.0/0', },
      { protocol => 'tcp',               security_group => 'devhops-agent', },
      { protocol => 'udp',               security_group => 'devhops-agent', },
      { protocol => 'icmp',              cidr => '0.0.0.0/0', },
    ],
  }

  ec2_instance { $instance_name:
    ensure    => running,
    image_id  => $ami,
    user_data => inline_epp($user_data),
  }
}
