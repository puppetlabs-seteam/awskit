# awskit::create_host
#
# Create a host in AWS
#
# @summary This define creates a host with given parameters
#
# @example
#   $user_data = @("USERDATA"/L)
#     #! /bin/bash
#     echo "${master_ip} master.inf.puppet.vm master" >> /etc/hosts
#     curl -k ${master_url} | bash -s agent:certname=${instance_name} extension_requests:pp_role=${role}
#     | USERDATA
#     aws::create_host { 'centos-demo-host':
#       $ami           = 'ami-ee6a718a',
#       $instance_type = 't2.small',
#       $user_data     = $user_data,
#       $security_groups = ['awskit-agent'],
#     }
define awskit::create_host (
  $ami,
  $instance_type,
  $user_data          = undef,
  $user_data_template = undef,
  $master_ip          = undef,
  $master_name        = undef,
  $run_agent          = true,
  $security_groups    = 'none',
  $key_name           = 'none',
  $role               = undef,
  $environment        = undef,
  $public_ip          = undef,
){

  include awskit

  $_master_ip = $master_ip ? {
    undef   => $awskit::master_ip,
    default => $master_ip,
  }

  $_master_name = $master_name ? {
    undef   => $awskit::master_name,
    default => $master_name,
  }

  $_security_groups = $security_groups ? {
    'none'  => "${facts['user']}-awskit-agent",
    default => $security_groups,
  }

  $_key_name = $key_name ? {
    'none'  => $awskit::key_name,
    default => $key_name,
  }

  $host_config = lookup("awskit::host_config.${name}", Hash, 'first', {})

  if $host_config['instance_type'] {
    $_instance_type = $host_config['instance_type']
  } else {
    $_instance_type = $instance_type
  }

  if $user_data and $user_data_template {
    fail('Only one of $user_data and $user_data_template should be specified')
  }

  if $user_data_template {

    $template_params = {
      certname    => $name,
      master_ip   => $_master_ip,
      master_name => $_master_name,
      environment => $environment,
      role        => $role,
      run_agent   => $run_agent,
    }

    $_user_data = epp($user_data_template, $template_params)

  } elsif $user_data {
    $_user_data = $user_data
  } else {
    $_user_data = undef
  }

  ec2_instance { $name:
    ensure            => running,
    region            => $awskit::region,
    availability_zone => $awskit::availability_zone,
    # need to specify subnet (although it's documented as optional)
    # if not, errors are generated:
    #  Error: Security groups 'awskit-agent' not found in VPCs 'vpc-fa3ddd93'
    #  Error: /Stage[main]/awskit::Create_agents/Ec2_instance[awskit-1]/ensure: 
    #   change from absent to running failed: Security groups 'awskit-agent' not found in VPCs 'vpc-fa3ddd93'
    #  see also https://github.com/puppetlabs/puppetlabs-aws/issues/191
    subnet            => $awskit::subnet,
    image_id          => $ami,
    security_groups   => $_security_groups,
    key_name          => $_key_name,
    tags              => $awskit::tags,
    instance_type     => $_instance_type,
    user_data         => $_user_data,
    require           => Ec2_securitygroup[$_security_groups],
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
