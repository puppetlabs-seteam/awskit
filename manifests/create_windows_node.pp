# awskit::create_windows_node
#
# @summary Creates a number of Windows nodes
#
# @summary Creates $count of Windows nodes
#
# @example
#   include awskit::create_windows_node
class awskit::create_windows_node (
  $instance_type,
  $count         = 1,
  $instance_name = 'awskit-windows',
){

  include awskit

  # create $count Windows nodes
  # password gets changed to "Devops!" by line 73 of data/common.yaml

  range(1,$count).each | $i | {
    awskit::create_host { "${instance_name}-${i}":
      ami                => $awskit::windows_ami,
      instance_type      => $instance_type,
      user_data_template => 'awskit/windows_userdata.epp',
    }
  }
}
