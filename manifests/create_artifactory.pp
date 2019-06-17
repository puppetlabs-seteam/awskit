# awskit::create_artifactory
#
# This class creates an instance in AWS for hosting a artifactory docker host.
#
# @summary Installs AWS instance for Artifactory as a Docker container.
#
# @example Using in a manifest
#   include awskit::create_artifactory
# @example Using with provision.sh task
#   tasks/provision.sh artifactory
#  
class awskit::create_artifactory (
  $instance_type,
  $instance_name = 'awskit-artifactory',
  $count = 1,
) {

  include awskit

  $ami = $awskit::centos_ami

  ec2_securitygroup { "${facts['user']}-awskit-artifactory":
    ensure      => 'present',
    region      => $awskit::region,
    vpc         => $awskit::vpc,
    description => 'Security group for Artifactory host',
    ingress     => [
      { protocol => 'tcp', port => 22,   cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 8081, cidr => '0.0.0.0/0', },
      { protocol => 'icmp',              cidr => '0.0.0.0/0', },
    ],
  }

  awskit::create_host { $instance_name:
    ami                   => $ami,
    instance_type         => $instance_type,
    user_data_template    => 'awskit/artifactory_userdata.epp',
    security_groups       => ["${facts['user']}-awskit-artifactory"],
    delete_on_termination => true
  }

}
