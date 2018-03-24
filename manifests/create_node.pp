# devhops::create_node

# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include devhops::create_agent
define devhops::create_node (
  $ami,
  $instance_type,
  $user_data,
  $install_puppet = true,
){

  include devhops

  # create $count CentOS nodes

  ec2_instance { $name:
    ensure            => running,
    region            => $devhops::region,
    availability_zone => $devhops::availability_zone,
    # need to specify subnet (although it's documented as optional)
    # if not, errors are generated:
    #  Error: Security groups 'devhops-agent' not found in VPCs 'vpc-fa3ddd93'
    #  Error: /Stage[main]/Devhops::Create_agents/Ec2_instance[devhops-1]/ensure: 
    #   change from absent to running failed: Security groups 'devhops-agent' not found in VPCs 'vpc-fa3ddd93'
    #  see also https://github.com/puppetlabs/puppetlabs-aws/issues/191
    subnet            => $devhops::subnet,
    image_id          => $ami,
    security_groups   => ['devhops-agent'],
    key_name          => $devhops::key_name,
    tags              => $devhops::tags,
    instance_type     => $instance_type,
    user_data         => inline_epp($user_data),
    require           => Ec2_securitygroup['devhops-agent'],
  }
}
