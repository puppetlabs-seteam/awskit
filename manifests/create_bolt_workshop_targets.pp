# awskit::create_bolt_workshop_targets
#
# This class creates Linux and Windows instances in AWS for the Puppet Bolt Workshop students to use as targets
#
# @summary Deploys Linux and Windows AWS instances as targets for Puppet Bolt Workshop
#
# @example
#   include awskit::create_bolt_workshop_targets
class awskit::create_bolt_workshop_targets (
  $instance_type_linux,
  $instance_type_windows,
  $user_data_linux,
  $user_data_windows,
  $count         = 15,
  $instance_name = 'awskit-boltws',
) {

  include awskit

  ec2_securitygroup { $awskit::boltws_sc_name:
    ensure      => 'present',
    region      => $awskit::region,
    vpc         => $awskit::vpc,
    description => 'SSH and WinRM ingress for Puppet Bolt Workshop',
    ingress     => [
      { protocol => 'tcp', port => 22,   cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 3389, cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 5985, cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 5986, cidr => '0.0.0.0/0', },
      { protocol => 'icmp',              cidr => '0.0.0.0/0', },
    ],
  }

  range(1,$count).each | $i | {
    #Create the Linux target
    awskit::create_host { "${instance_name}-linux-student${i}":
      ami             => $awskit::centos_ami,
      instance_type   => $instance_type_linux,
      user_data       => $user_data_linux,
      security_groups => [$awskit::boltws_sc_name],
      key_name        => lookup('awskit::boltws_key_name'),

    }

    #Create the Windows target
    awskit::create_host { "${instance_name}-windows-student${i}":
      ami             => $awskit::windows_ami,
      instance_type   => $instance_type_windows,
      user_data       => $user_data_windows,
      security_groups => [$awskit::boltws_sc_name],
      key_name        => lookup('awskit::boltws_key_name'),
    }
  }
}
