# devhops::create
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include devhops::create_agents
class devhops::create_wsus (
  $instance_type,
  $user_data,
  $count         = 1,
  $instance_name = 'wsus',
){

  include devhops

  # create $count Windows nodes

  range(1,$count).each | $i | {
    devhops::create_node { "${instance_name}-${i}":
      ami           => $devhops::windows_ami,
      instance_type => $instance_type,
      user_data     => inline_epp($user_data),
    }
  }
}
