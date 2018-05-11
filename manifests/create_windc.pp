# awskit::create_windc
#
# This class creates an instance in AWS for a Windows Domain Controller to be installed on
#
# @summary Installs AWS instance for Windows Domain Controller installation
#
# @example
#   include awskit::create_windc
class awskit::create_windc (
  $instance_type,
  $user_data,
  $instance_name = 'awskit-windc',
  $count = 1,
) {

  include awskit

  $ami = $awskit::windc_ami

  ec2_securitygroup { 'awskit-windc':
    ensure      => 'present',
    region      => $awskit::region,
    vpc         => $awskit::vpc,
    description => 'RDP ingress for awskit Windows DC',
    ingress     => [
      { protocol => 'tcp', port => 3389, cidr => '0.0.0.0/0', },
      { protocol => 'tcp',               security_group => 'awskit-agent', },
      { protocol => 'udp',               security_group => 'awskit-agent', },
      { protocol => 'icmp',              cidr => '0.0.0.0/0', },
    ],
  }

  awskit::create_host { $instance_name:
    ami             => $ami,
    instance_type   => $instance_type,
    user_data       => inline_epp($user_data),
    security_groups => ['awskit-windc'],
    require         => Ec2_securitygroup['awskit-windc'],
  }

}
