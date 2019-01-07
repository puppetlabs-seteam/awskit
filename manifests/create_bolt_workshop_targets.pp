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
  $master_ip,
  $count         = 15,
  $instance_name = 'awskit-boltws',
) {

  include awskit

  ec2_securitygroup { "${facts['user']}-awskit-boltws":
    ensure      => 'present',
    region      => $awskit::region,
    vpc         => $awskit::vpc,
    description => 'Ingress rules for Puppet Bolt Workshop',
    ingress     => [
      { protocol => 'tcp', port => 22,   cidr => '0.0.0.0/0', }, # SSH
      { protocol => 'tcp', port => 443,  cidr => '0.0.0.0/0', }, # PE Console HTTPS
      { protocol => 'tcp', port => 3389, cidr => '0.0.0.0/0', }, # RDP
      { protocol => 'tcp', port => 5985, cidr => '0.0.0.0/0', }, # WinRM HTTP
      { protocol => 'tcp', port => 5986, cidr => '0.0.0.0/0', }, # WinRM HTTPS
      { protocol => 'tcp', port => 8140, cidr => '0.0.0.0/0', }, # Puppet Server
      { protocol => 'tcp', port => 8142, cidr => '0.0.0.0/0', }, # PE Orchestrator
      { protocol => 'tcp', port => 8143, cidr => '0.0.0.0/0', }, # PE Orchestrator
      { protocol => 'tcp', port => 8170, cidr => '0.0.0.0/0', }, # PE Code Manager
      { protocol => 'icmp',              cidr => '0.0.0.0/0', }, # Ping
    ],
  }

  #Create the Linux target for teacher
  awskit::create_host { "${instance_name}-linux-teacher":
    ami             => $awskit::centos_ami,
    instance_type   => $instance_type_linux,
    user_data       => $user_data_linux,
    security_groups => ["${facts['user']}-awskit-boltws"],
    key_name        => lookup('awskit::boltws_key_name'),

  }

  #Create the Windows target for teacher
  awskit::create_host { "${instance_name}-windows-teacher":
    ami             => $awskit::windows_ami,
    instance_type   => $instance_type_windows,
    user_data       => $user_data_windows,
    security_groups => ["${facts['user']}-awskit-boltws"],
    key_name        => lookup('awskit::boltws_key_name'),
  }

  range(1,$count).each | $i | {
    #Create the Linux targets for students
    awskit::create_host { "${instance_name}-linux-student${i}":
      ami             => $awskit::centos_ami,
      instance_type   => $instance_type_linux,
      user_data       => $user_data_linux,
      security_groups => ["${facts['user']}-awskit-boltws"],
      key_name        => lookup('awskit::boltws_key_name'),
    }

    #Create the Windows targets for students
    awskit::create_host { "${instance_name}-windows-student${i}":
      ami             => $awskit::windows_ami,
      instance_type   => $instance_type_windows,
      user_data       => $user_data_windows,
      security_groups => ["${facts['user']}-awskit-boltws"],
      key_name        => lookup('awskit::boltws_key_name'),
    }
  }
}
