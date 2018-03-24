# devhops::create_master
#
# Provision a Puppetmaster in AWS
#
# @summary Provision a Puppetmaster in AWS
#
# @example
#   include devhops::create_master
class devhops::create_master (
  $instance_type,
  $user_data,
  $control_repo,
  $gogs_ssh_keys,
  $instance_name = 'pm-devhops',
) {

  include devhops

  $pm_ami = $devhops::pm_ami

  # puppetmaster
  ec2_instance { $instance_name:
    ensure            => running,
    region            => $devhops::region,
    availability_zone => $devhops::availability_zone,
    key_name          => $devhops::key_name,
    image_id          => $pm_ami,
    instance_type     => $instance_type,
    subnet            => $devhops::subnet,
    security_groups   => ['devhops-master'],
    tags              => $devhops::tags,
    user_data         => inline_epp($user_data),
    require           => Ec2_securitygroup['devhops-master'],
  }

  ec2_elastic_ip { $devhops::master_ip:
    ensure   => 'attached',
    instance => $instance_name,
    region   => $devhops::region,
  }

}
