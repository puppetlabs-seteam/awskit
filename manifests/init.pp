# awskit
#
# Provides a central place to configure parameters using hiera.
# Also selects the right AMI ids based on current region.
# 
# @summary Placeholder for hiera parameters
#
# @example
#   include awskit
# 
# @param key_name Name of the AWS keypair, this is region-dependent.
# @param region this is the AWS region, looked up in hiera. Hiera gets it from the aws_region fact 
#   which you can set with the `FACTER_aws_region` environment variable. 
#   Also recommended to set the `AWS_REGION` enviroinment variable to the same 
#   region since this speeds up the puppetlabs/aws module considerably)
# @param vpc The VPC the instances should go into. awskit currently does not create VPCs or subnets,
#   these should be present in the region and configured in `%{::aws_region}/common.yaml`. Note that the VPC
#   in AWS needs to have a name so if it doesn't, you need to provide that using the AWS console. 
# @param availability_zone The availability zone the instances should go into. Should be
#   configured in `%{::aws_region}/common.yaml`.
# @param subnet The subnet the instances should go into. Should be configured 
#   in `%{::aws_region}/common.yaml`. Note that the subnet in AWS needs to have a name
#   so if it doesn't you need to provide that using the AWS console.
# @param tags AWS instance tags. Provided in common.yaml. The created_by tag can be provided
#   in `%{::user}.yaml` and deep merged.
# @param master_ip AWS PM master IP address. Since this address should not change across
#   instance restarts, you would need an Elastic IP address for this. See README for the AWS cli command to create one.
# @param amis The central hash of AMIs, which lives on `common.yaml`. Rather than providing AMIs per region,
#   they are all in the same hash for easier maintenance. This class creates variables with the correct AMIs based on the region.
# @param wsus_ip The IP address for the WSUS server, if you use it in your environment. Also needs an EIP (see `master_ip`).
# @param master_name The name of the puppetmaster.
# @param ssh_ingress_cidrs The ingress CIDR for ssh access of the master.
class awskit(
  String $key_name,
  String $region,
  String $vpc,
  String $availability_zone,
  String $subnet,
  Hash $tags,
  String $master_ip,
  Hash $amis,
  String $wsus_ip = '',
  String $master_name = 'master.inf.puppet.vm',
  Array[String] $ssh_ingress_cidrs = [],
  ) {

    $version_required = '5.0.0'
    if versioncmp($::puppetversion, $version_required) < 0 { # agent version < $version_required
      fail("awskit requires agent version >= ${version_required}, found: ${::puppetversion}")
    }

    $pm_ami          = $amis[$region]['pm']
    $docker_ami      = $amis[$region]['docker']
    $centos_ami      = $amis[$region]['centos']
    $windows_ami     = $amis[$region]['windows']
    $discovery_ami   = $amis[$region]['discovery']
    $windc_ami       = $amis[$region]['windc']
    $wsus_ami        = $amis[$region]['wsus']

    # notify { "tags: ${tags}": }

#TODO: make this more secure

    $default_ingress = [
      { protocol => 'tcp',  port => 81,        security_group => "${facts['user']}-awskit-agent", }, # PE fileserver
      { protocol => 'tcp',  port => 443,       cidr => '0.0.0.0/0', }, # PE Console
      { protocol => 'tcp',  port => 3000,      cidr => '0.0.0.0/0', }, # Gogs
      { protocol => 'tcp',  port => 4433,      cidr => '0.0.0.0/0', }, # PE Classifier
      { protocol => 'tcp',  port => 8081,      cidr => '0.0.0.0/0', }, # PuppetDB
      { protocol => 'tcp',  port => 8140,      cidr => '0.0.0.0/0', }, # Puppet Server
      { protocol => 'tcp',  port => 8142,      cidr => '0.0.0.0/0', }, # PE Orchestrator
      { protocol => 'tcp',  port => 8143,      cidr => '0.0.0.0/0', }, # PE Orchestrator
      { protocol => 'tcp',  port => 8170,      cidr => '0.0.0.0/0', }, # PE Code Manager
      { protocol => 'tcp',  port => 61613,     cidr => '0.0.0.0/0', }, # MCollective
      { protocol => 'icmp',                    cidr => '0.0.0.0/0', }
    ]

    $ssh_ingress = $ssh_ingress_cidrs.map | $ssh_rule | {
      { protocol => 'tcp',  port => 22, cidr => $ssh_rule }
    }

    $ingress = flatten([$default_ingress, $ssh_ingress])

    ec2_securitygroup { "${facts['user']}-awskit-master":
      ensure      => present,
      region      => $awskit::region,
      vpc         => $awskit::vpc,
      description => 'SG for awskit Master',
      ingress     => $ingress,
    }

    ec2_securitygroup { "${facts['user']}-awskit-agent":
      ensure      => 'present',
      region      => $awskit::region,
      vpc         => $awskit::vpc,
      description => 'ssh and http(s) ingress for awskit agent',
      ingress     => [
        { protocol => 'tcp', port => 22,   cidr => '0.0.0.0/0', },
        { protocol => 'tcp', port => 80,   cidr => '0.0.0.0/0', },
        { protocol => 'tcp', port => 443,  cidr => '0.0.0.0/0', },
        { protocol => 'tcp', port => 3306, security_group => "${facts['user']}-awskit-agent", }, # MySQL
        { protocol => 'tcp', port => 3389, cidr => '0.0.0.0/0', }, # RDP
        { protocol => 'tcp', port => 5985, cidr => '0.0.0.0/0', }, # WinRM HTTP
        { protocol => 'tcp', port => 5986, cidr => '0.0.0.0/0', }, # WinRM HTTPS
        { protocol => 'tcp', port => 8080, cidr => '0.0.0.0/0', },
        { protocol => 'tcp', port => 8888, security_group => "${facts['user']}-awskit-agent", }, # rgbank webhead
        { protocol => 'icmp',              cidr => '0.0.0.0/0', },
      ],
    }

}
