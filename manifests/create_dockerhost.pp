# awskit::create_dockerhost
#
# This class creates an instance in AWS for Puppet Discovery to be installed on
#
# @summary Installs AWS instance for Puppet Discovery installation
#
# @example
#   include awskit::create_dockerhost
class awskit::create_dockerhost (
  $instance_type,
  $count         = 1,
  $instance_name = 'awskit-dockerhost',
) {

  include awskit

  $ami = $awskit::centos_ami

  ec2_securitygroup { "${facts['user']}-awskit-dockerhost":
    ensure      => 'present',
    region      => $awskit::region,
    vpc         => $awskit::vpc,
    description => 'ingress for awskit dockerhost',
    ingress     => [
      { protocol => 'tcp', port => 22,   cidr => '0.0.0.0/0', },   # ssh
      { protocol => 'tcp', port => 80,   cidr => '0.0.0.0/0', },   # http
      { protocol => 'tcp', port => 443,  cidr => '0.0.0.0/0', },   # https
      { protocol => 'tcp', port => 8000,   cidr => '0.0.0.0/0', }, # splunk
      { protocol => 'tcp', port => 8080,   cidr => '0.0.0.0/0', }, # discovery
      { protocol => 'tcp', port => 8443,   cidr => '0.0.0.0/0', }, # discovery
      { protocol => 'icmp',              cidr => '0.0.0.0/0', },
    ],
  }

  awskit::create_host { $instance_name:
    ami                => $ami,
    instance_type      => $instance_type,
    user_data_template => 'awskit/dockerhost_userdata.epp',
    security_groups    => ["${facts['user']}-awskit-dockerhost"],
  }
}
