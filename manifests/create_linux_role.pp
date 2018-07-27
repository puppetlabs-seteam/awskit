# awskit::create_linux_role
#
# Creates a number of Linux nodes with a role
#
# @summary Creates $count Linux nodes with a role
#
# @example
#   include awskit::create_linux_role
class awskit::create_linux_role (
  $role,
  $instance_type  = lookup('awskit::create_linux_node::instance_type'),
  $user_data      = lookup('awskit::create_linux_node::user_data'),
  $instance_name  = 'awskit-linux',
  $count          = 1,
){

  include awskit

  # create $count CentOS nodes

  range(1,$count).each | $i | {
    awskit::create_host { "${instance_name}-${role}-${i}":
      role          => $role,
      ami           => $awskit::centos_ami,
      instance_type => $instance_type,
      user_data     => $user_data,
    }
  }
}
