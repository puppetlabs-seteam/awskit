# awskit::create_gitlab
#
# This class creates an instance in AWS for hosting a gitlab docker host.
#
# @summary Installs AWS instance for gitlab installation. Auto-configures
#   the role `gitlab_server` which is available in the control repo.
#
# @note
# 
#  The gitlab_server role was added in the tse control repo as of 10/2018.
#  The gitlab server that is provisioned will automatically be classfied.
# 
# @example Using in a manifest
#   include awskit::create_gitlab
# @example Using with provision.sh task
#   tasks/provision.sh gitlab
#  
class awskit::create_gitlab (
  $instance_type,
  $instance_name = 'awskit-gitlab',
  $count = 1,
) {

  include awskit

  $ami = $awskit::centos_ami

  ec2_securitygroup { "${facts['user']}-awskit-gitlab":
    ensure      => 'present',
    region      => $awskit::region,
    vpc         => $awskit::vpc,
    description => 'Security group for gitlab host',
    ingress     => [
      { protocol => 'tcp', port => 22,   cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 80,   cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 2222, cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 7000, cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 8000, cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 8080, cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 8081, cidr => '0.0.0.0/0', },
      { protocol => 'icmp',              cidr => '0.0.0.0/0', },
    ],
  }

  awskit::create_host { $instance_name:
    ami                => $ami,
    role               => 'git_server',
    instance_type      => $instance_type,
    user_data_template => 'awskit/linux_userdata.epp',
    security_groups    => ["${facts['user']}-awskit-gitlab"],
  }

}
