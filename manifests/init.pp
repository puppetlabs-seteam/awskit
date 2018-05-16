# awskit
#
# Provides a central place to configure parameters using hiera.
# Also selects the right AMI ids based on current region
# 
# @summary Placeholder for hiera parameters
#
# @example
#   include awskit
class awskit(
  $key_name,
  $region,
  $vpc,
  $availability_zone,
  $subnet,
  $tags,
  $master_ip,
  $amis,
  $wsus_ip = undef,
  $ssh_ingress_ips = ['0.0.0.0/0'],
  ) {

    $pm_ami         = $amis[$region]['pm']
    $centos_ami     = $amis[$region]['centos']
    $windows_ami    = $amis[$region]['windows']
    $discovery_ami  = $amis[$region]['discovery']
    $windc_ami      = $amis[$region]['windc']
    $wsus_ami       = $amis[$region]['wsus']

    $default_ingress = [
        { protocol => 'tcp',  port => 22,        cidr => '0.0.0.0/0', },
        { protocol => 'tcp',  port => 443,       cidr => '0.0.0.0/0', },
        { protocol => 'tcp',  port => 3000,      cidr => '0.0.0.0/0', },
        { protocol => 'tcp',  port => 8140,      cidr => '0.0.0.0/0', },
        { protocol => 'tcp',  port => 8142,      cidr => '0.0.0.0/0', },
        { protocol => 'tcp',  port => 8143,      cidr => '0.0.0.0/0', },
        { protocol => 'tcp',  port => 8170,      cidr => '0.0.0.0/0', },
        { protocol => 'tcp',  port => 61613,     cidr => '0.0.0.0/0', },
        { protocol => 'icmp',                    cidr => '0.0.0.0/0', }
      ]

    $ssh_ingress = $ssh_ingress_ips.map | $ssh_rule | {
      { protocol => 'tcp',  port => 22, cidr => $ssh_rule }
    }

    notice($ssh_ingress)

    $ingress = flatten([$default_ingress, $ssh_ingress])

    notice($ingress)

    ec2_securitygroup { 'awskit-master':
      ensure      => 'present',
      region      => $awskit::region,
      vpc         => $awskit::vpc,
      description => 'SG for awskit Master',
      ingress     => $ingress,
    }

    ec2_securitygroup { 'awskit-agent':
      ensure      => 'present',
      region      => $awskit::region,
      vpc         => $awskit::vpc,
      description => 'ssh and http(s) ingress for awskit agent',
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
