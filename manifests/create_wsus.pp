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

  $wsus_ami = $devhops::wsus_ami

  # create puppetmaster instance
  devhops::create_node { $instance_name:
    ami             => $wsus_ami,
    instance_type   => $instance_type,
    user_data       => inline_epp($user_data),
    security_groups => ['devhops-wsus'],
    require         => Ec2_securitygroup['devhops-wsus'],
  }

  ec2_securitygroup { 'devhops-wsus':
    ensure      => 'present',
    region      => $devhops::region,
    vpc         => $devhops::vpc,
    description => 'RDP ingress for DevHops Windows WSUS',
    ingress     => [
      { protocol => 'tcp', port => 3389, cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 8530, cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 8531, cidr => '0.0.0.0/0', },
      { protocol => 'tcp',               security_group => 'devhops-agent', },
      { protocol => 'udp',               security_group => 'devhops-agent', },
      { protocol => 'icmp',              cidr => '0.0.0.0/0', },
    ],
  }

}
