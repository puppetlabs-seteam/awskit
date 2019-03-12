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
  $role           = undef,
  $environment    = undef,
  $instance_name  = 'awskit-linux',
  $count          = 1,
){

  include awskit

  # create $count Linux nodes

  range(1,$count).each | $i | {
    awskit::create_host { "${instance_name}-${i}":
      ami                => $awskit::centos_ami,
      instance_type      => $instance_type,
      user_data_template => 'awskit/linux_userdata.epp',
      role               => $role,
      environment        => $environment,
      block_devices      => [
      {
        'device_name'           => '/dev/sda1',
        'volume_size'           => 8,
        'delete_on_termination' => true
      }],
    }
  }
}
