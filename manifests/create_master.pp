# devhops::create
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include devhops::create
class devhops::create_master (
  $pm_ami,
  $instance_type,
) {

  include devhops

  Ec2_instance {
    region            => $devhops::region,
    availability_zone => $devhops::availability_zone,
    key_name          => $devhops::key_name,
  }

  ec2_securitygroup { 'devhops-master':
    ensure      => 'present',
    region      => $devhops::region,
    vpc         => $devhops::vpc,
    description => 'SG for DevHops Master',
    ingress     => [
      { protocol => 'tcp',  port => 22,        cidr => '0.0.0.0/0', },
      { protocol => 'tcp',  port => 443,       cidr => '0.0.0.0/0', },
      { protocol => 'tcp',  port => 3000,      cidr => '0.0.0.0/0', },
      { protocol => 'tcp',  port => 8140,      cidr => '0.0.0.0/0', },
      { protocol => 'tcp',  port => 8142,      cidr => '0.0.0.0/0', },
      { protocol => 'tcp',  port => 8143,      cidr => '0.0.0.0/0', },
      { protocol => 'tcp',  port => 8170,      cidr => '0.0.0.0/0', },
      { protocol => 'tcp',  port => 61613,     cidr => '0.0.0.0/0', },
      { protocol => 'icmp',                    cidr => '0.0.0.0/0', },
    ],
  }

  # puppetmaster
  ec2_instance { 'pm-devhops':
    ensure          => running,
    image_id        => $pm_ami,
    instance_type   => $instance_type,
    # If a subnet is specified, creatin of ec2 instance fails.
    # possible reason: https://github.com/puppetlabs/puppetlabs-aws/issues/191
    subnet          => $devhops::subnet,
    # security_groups => ['Puppet Enterprise -BYOL--2017-2-1 BYOL-AutogenByAWSMP-1', 'pe-gogs'],
    security_groups => ['devhops-master'],
    tags            => $devhops::tags,
    require         => Ec2_securitygroup['devhops-master'],
  }

}
