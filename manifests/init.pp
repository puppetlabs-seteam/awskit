# devhops
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include devhops
class devhops(
  $key_name,
  $region,
  $vpc,
  $availability_zone,
  $subnet,
  $tags,
  $master_ip,
  $amis,
  ) {

    $pm_ami         = $amis[$region]['pm']
    $centos_ami     = $amis[$region]['centos']
    $windows_ami    = $amis[$region]['windows']
    $discovery_ami  = $amis[$region]['discovery']
    $windc_ami      = $amis[$region]['windc']
    $windc_wsus     = $amis[$region]['wsus']

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

}
