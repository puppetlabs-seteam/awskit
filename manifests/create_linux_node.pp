# awskit::create_linux_node
#
# Creates a number of Linux nodes
#
# @summary Creates $count Linux nodes
#
# @example
#   include awskit::create_linux_node
class awskit::create_linux_node (
  $instance_type,
  $user_data,
  $role           = undef,
  $environment    = undef,
  $instance_name  = 'awskit-linux',
  $count          = 1,
){

  include awskit

  # create $count Linux nodes

  range(1,$count).each | $i | {
    awskit::create_host { "${instance_name}-${i}":
      ami           => $awskit::centos_ami,
      instance_type => $instance_type,
      user_data     => $user_data,
      role          => $role,
      environment   => $environment,
    }
  }
}
