  $role          = 'sample_website'
  $master_ip     = '35.177.92.181'
  $master_url    = 'https://master.inf.puppet.vm:8140/packages/current/install.bash'
  $instance_name = 'devhops-demo-host'

  $user_data = @("USERDATA"/L)
    #! /bin/bash
    echo "${master_ip} master.inf.puppet.vm master" >> /etc/hosts
    curl -k ${master_url} | bash -s agent:certname=${instance_name} extension_requests:pp_role=${role}
    | USERDATA

  ec2_instance { $instance_name:
    ensure            => running,
    region            => 'eu-west-2',
    availability_zone => 'eu-west-2a',
    subnet            => 'subnet-default-2a',
    image_id          => 'ami-ee6a718a',
    security_groups   => ['devhops-agent'],
    key_name          => 'dimitri.tischenko-eu-west-2',
    instance_type     => 't2.micro',
    user_data         => $user_data,
  }
