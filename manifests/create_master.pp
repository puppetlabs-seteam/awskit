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
  $count         = 1,
  $instance_name = 'awskit-pm',
) {

  include awskit

  $pm_ami = $awskit::pm_ami

  $public_ip = lookup('awskit::master_ip', { default_value => undef })

  # create puppetmaster instance
  awskit::create_host { $instance_name:
    ami             => $pm_ami,
    instance_type   => $instance_type,
    user_data       => undef,
    security_groups => ["${facts['user']}-awskit-master"],
    public_ip       => $public_ip,
  }

}
