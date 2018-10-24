# awskit::create_cd4pe
#
# This class creates an instance in AWS for hosting a cd4pe docker host.
#
# @summary Installs AWS instance for CD4PE installation. Auto-configures
#   the role `cd4pe` which needs to be available in the control repo.
#
# @note
# 
#   At this moment (June 16 2018), you need this control repo:
#   https://github.com/puppetlabs/controlrepo-cd4pe-hol
#   to use CD4PE in AWS successfully.    
# 
# @example Using in a manifest
#   include awskit::create_cd4pe
# @example Using with provision.sh task
#   tasks/provision.sh cd4pe
#  
class awskit::create_cd4pe (
  $instance_type,
  $user_data = lookup('awskit::create_linux_node::user_data'),
  $instance_name = 'awskit-cd4pe',
  $count = 1,
) {

  include awskit

  $ami = $awskit::centos_ami

  ec2_securitygroup { $awskit::cd4pe_sc_name:
    ensure      => 'present',
    region      => $awskit::region,
    vpc         => $awskit::vpc,
    description => 'Security group for CD4PE host',
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
    ami             => $ami,
    role            => 'cd4pe_server',
    instance_type   => $instance_type,
    user_data       => $user_data,
    security_groups => [$awskit::cd4pe_sc_name],
  }

}
