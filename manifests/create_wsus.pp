# devhops::create
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include devhops::create_agents
class devhops::create_wsus (
  $instance_type,
  $user_data,
  $count         = 1,
  $instance_name = 'wsus',
){

  include devhops

  $ami = $devhops::wsus_ami

  Ec2_instance {
    instance_type     => $instance_type,
    region            => $devhops::region,
    availability_zone => $devhops::availability_zone,
    subnet            => $devhops::subnet,
    security_groups   => ['devhops-wsus'],
    key_name          => $devhops::key_name,
    tags              => $devhops::tags,
    require           => Ec2_securitygroup['devhops-wsus'],
  }

  ec2_securitygroup { 'devhops-wsus':
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
