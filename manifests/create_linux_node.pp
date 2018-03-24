# devhops::create_node
#
# Create an agent
#
# @summary Creates a machine with or without a puppet agent
#
# @example
#   include devhops::create_agents
class devhops::create_linux_node (
  $instance_type,
  $user_data,
  $instance_name  = 'linhops',
  $count          = 1,
){

  include devhops

  # create $count CentOS nodes

  range(1,$count).each | $i | {
    devhops::create_node { "${instance_name}-${i}":
      ami           => $devhops::centos_ami,
      instance_type => $instance_type,
      user_data     => inline_epp($user_data),
      require       => Ec2_securitygroup['devhops-agent'],
    }
  }
}
