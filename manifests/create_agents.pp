# devhops::create
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include devhops::create_agents
class devhops::create_agents (
  $instance_type_lin,
  $instance_type_win,
  $centos_ami,
  $windows_ami,
  $centos_count,
  $centos_user_data,
  $windows_count,
  $windows_user_data,
){

  include devhops

  Ec2_instance {
    region            => $devhops::region,
    availability_zone => $devhops::availability_zone,
    # need to specify subnet (although it's documented as optional)
    # if not, errors are generated:
    #  Error: Security groups 'devhops-agent' not found in VPCs 'vpc-fa3ddd93'
    #  Error: /Stage[main]/Devhops::Create_agents/Ec2_instance[devhops-1]/ensure: 
    #   change from absent to running failed: Security groups 'devhops-agent' not found in VPCs 'vpc-fa3ddd93'
    #  see also https://github.com/puppetlabs/puppetlabs-aws/issues/191
    subnet            => $devhops::subnet,
    security_groups   => ['devhops-agent'],
    key_name          => $devhops::key_name,
    tags              => $devhops::tags,
    require           => Ec2_securitygroup['devhops-agent'],
  }

  ec2_securitygroup { 'devhops-agent':
    ensure      => 'present',
    region      => $devhops::region,
    vpc         => $devhops::vpc,
    description => 'ssh and http(s) ingress for DevHops agent',
    ingress     => [
      { protocol => 'tcp', port => 22,   cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 80,   cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 443,  cidr => '0.0.0.0/0', },
      { protocol => 'tcp', port => 3389, cidr => '0.0.0.0/0', }, # RDP
      { protocol => 'tcp', port => 5985, cidr => '0.0.0.0/0', }, # WinRM HTTP
      { protocol => 'tcp', port => 5986, cidr => '0.0.0.0/0', }, # WinRM HTTPS
      { protocol => 'tcp', port => 8080, cidr => '0.0.0.0/0', },
      { protocol => 'icmp',              cidr => '0.0.0.0/0', },
    ],
  }

  # create $centos_count CentOS nodes

  range(1,$centos_count).each | $i | {
    ec2_instance { "linhops-${i}":
      ensure        => running,
      image_id      => $centos_ami,
      instance_type => $instance_type_lin,
      user_data     => inline_epp($centos_user_data),
    }
  }

  # create $windows_count Windows nodes

  range(1,$windows_count).each | $i | {
    ec2_instance { "winhops-${i}":
      ensure        => running,
      image_id      => $windows_ami,
      instance_type => $instance_type_win,
      user_data     => inline_epp($windows_user_data),
    }
  }
}
