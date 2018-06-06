# awskit::create_master
#
# Provision a Puppetmaster in AWS
#
# @summary Provision a Puppetmaster in AWS
#
# @example
#   include awskit::create_master
class awskit::create_master (
  $instance_type,
  $user_data     = '',
  $count         = 1,
  $instance_name = 'awskit-pm',
) {

  include awskit

  $pm_ami = $awskit::pm_ami

  # create puppetmaster instance
  awskit::create_host { $instance_name:
    ami             => $pm_ami,
    instance_type   => $instance_type,
    user_data       => inline_epp($user_data),
    security_groups => ['awskit-master'],
    require         => Ec2_securitygroup['awskit-master'],
  }

}
