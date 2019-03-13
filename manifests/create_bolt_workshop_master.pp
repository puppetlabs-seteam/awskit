# awskit::create_bolt_workshop_master
#
# This class creates the PE Master in AWS for the Puppet Bolt Workshop
#
# @summary Creates the PE Master AWS instance for Puppet Bolt Workshop
#
# @example
#   include awskit::create_bolt_workshop_master
class awskit::create_bolt_workshop_master (
  $instance_type,
  $instance_name = 'awskit-boltws-master',
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

  #Create the PE Master
  awskit::create_host { $instance_name:
    ami                   => $awskit::centos_ami,
    instance_type         => $instance_type,
    security_groups       => ["${facts['user']}-awskit-boltws"],
    delete_on_termination => true
  }

}
