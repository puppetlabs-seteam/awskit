# awskit::create_host

# Create a host in AWS
#
# @summary This define creates a host with given parameters
#
# @example
#
# $_user_data = @("USERDATA"/L)
#   #! /bin/bash
#   echo "${master_ip} master.inf.puppet.vm master" >> /etc/hosts
#   curl -k ${master_url} | bash -s agent:certname=${instance_name} extension_requests:pp_role=${role}
#   | USERDATA
#
#   aws::create_host { 'centos-demo-host':
#     $ami           = 'ami-ee6a718a',
#     $instance_type = 't2.small',
#     $instance_type = 't2.small',
#     $user_data     = $_user_data,
#     $security_groups = ['awskit-agent'],
#   }

define awskit::create_host (
  $ami,
  $instance_type,
  $user_data,
  $security_groups = 'none',
  $run_agent       = true,
  $role            = undef,
  $environment     = undef,
  $public_ip       = undef,
){

  include awskit

  $_security_groups = $security_groups ? {
    'none'  => $awskit::agent_sc_name,
    default => $security_groups,
  }

  $host_config = lookup("awskit::host_config.${name}", Hash, 'first', {})

  if $host_config['instance_type'] {
    $_instance_type = $host_config['instance_type']
  } else {
    $_instance_type = $instance_type
  }

  ec2_instance { $name:
    ensure                      => running,
    region                      => $awskit::region,
    availability_zone           => $awskit::availability_zone,
    # need to specify subnet (although it's documented as optional)
    # if not, errors are generated:
    #  Error: Security groups 'awskit-agent' not found in VPCs 'vpc-fa3ddd93'
    #  Error: /Stage[main]/awskit::Create_agents/Ec2_instance[awskit-1]/ensure: 
    #   change from absent to running failed: Security groups 'awskit-agent' not found in VPCs 'vpc-fa3ddd93'
    #  see also https://github.com/puppetlabs/puppetlabs-aws/issues/191
    subnet                      => $awskit::subnet,
    image_id                    => $ami,
    security_groups             => $_security_groups,
    key_name                    => $awskit::key_name,
    tags                        => $awskit::tags,
    instance_type               => $_instance_type,
    user_data                   => inline_epp($user_data),
    associate_public_ip_address => true,
    require                     => Ec2_securitygroup[$_security_groups],
  }

  $_public_ip = $public_ip ? {
    undef   => $host_config['public_ip'],
    default => $public_ip,
  }

  if $_public_ip {
    ec2_elastic_ip { $_public_ip:
      ensure   => 'attached',
      instance => $name,
      region   => $awskit::region,
    }
  }
}
