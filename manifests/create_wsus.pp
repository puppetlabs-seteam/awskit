# awskit::create
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include awskit::create_agents
class awskit::create_wsus (
  $instance_type,
  $user_data,
  $count         = 1,
  $instance_name = 'awskit-wsus',
){

  include awskit

  $wsus_ami = $awskit::wsus_ami

  # create puppetmaster instance
  awskit::create_host { $instance_name:
    ami             => $wsus_ami,
    instance_type   => $instance_type,
    user_data       => $user_data,
    security_groups => [$awskit::wsus_sc_name],
  }

  ec2_securitygroup { $awskit::wsus_sc_name:
    ensure      => 'present',
    region      => $awskit::region,
    vpc         => $awskit::vpc,
    description => 'RDP ingress for awskit Windows WSUS',
    ingress     => [
      { protocol => 'tcp', port => 3389, cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 8530, cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 8531, cidr => '0.0.0.0/0', },
      { protocol => 'tcp',               security_group => $awskit::agent_sc_name, },
      { protocol => 'udp',               security_group => $awskit::agent_sc_name, },
      { protocol => 'icmp',              cidr => '0.0.0.0/0', },
    ],
  }

}
