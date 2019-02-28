# awskit::create_bolt_workshop_targets
#
# This class creates Linux and Windows instances in AWS for the Puppet Bolt Workshop students to use as targets
#
# @summary Deploys Linux and Windows AWS instances as targets for Puppet Bolt Workshop
#
# @example
#   include awskit::create_bolt_workshop_targets
class awskit::create_bolt_workshop_targets (
  $instance_type_linux,
  $instance_type_windows,
  $master_ip,
  $count         = 15,
  $instance_name = 'awskit-boltws',
) {

  include awskit

  ec2_securitygroup { "${facts['user']}-awskit-boltws":
    ensure      => 'present',
    region      => $awskit::region,
    vpc         => $awskit::vpc,
    description => 'Ingress rules for Puppet Bolt Workshop',
    ingress     => [
      { protocol => 'tcp', port => 22,   cidr => '0.0.0.0/0', }, # SSH
      { protocol => 'tcp', port => 443,  cidr => '0.0.0.0/0', }, # PE Console HTTPS
      { protocol => 'tcp', port => 3389, cidr => '0.0.0.0/0', }, # RDP
      { protocol => 'tcp', port => 5985, cidr => '0.0.0.0/0', }, # WinRM HTTP
      { protocol => 'tcp', port => 5986, cidr => '0.0.0.0/0', }, # WinRM HTTPS
      { protocol => 'tcp', port => 8140, cidr => '0.0.0.0/0', }, # Puppet Server
      { protocol => 'tcp', port => 8142, cidr => '0.0.0.0/0', }, # PE Orchestrator
      { protocol => 'tcp', port => 8143, cidr => '0.0.0.0/0', }, # PE Orchestrator
      { protocol => 'tcp', port => 8170, cidr => '0.0.0.0/0', }, # PE Code Manager
      { protocol => 'icmp',              cidr => '0.0.0.0/0', }, # Ping
    ],
  }

  $user_data_linux = @(EOL)
    #! /bin/bash
    echo "<%= $master_ip %> <%= $awskit::master_name %> master" >> /etc/hosts
    sed -i -r -e '/^\s*Defaults\s+secure_path/ s[=(.*)[=\1:/opt/puppetlabs/bin[' /etc/sudoers
    hostnamectl set-hostname <%= $auto_name %>
    rpm -Uvh https://yum.puppet.com/puppet6/puppet6-release-el-7.noarch.rpm
    yum install -y puppet-agent
    shutdown -r +1
    | EOL

  $user_data_windows = @(EOW)
    <powershell>
    $hosts = "$env:windir\System32\drivers\etc\hosts" ;
    "<%= $master_ip %> <%= $awskit::master_name %> master" | Add-Content -PassThru $hosts ;
    net user Administrator "BoltR0cks!" ;
    wmic USERACCOUNT WHERE "Name='Administrator'" set PasswordExpires=FALSE ;
    [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true} ; 
    Set-ExecutionPolicy Bypass -Scope Process -Force ;
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) ;
    winrm quickconfig -force ;
    Enable-NetFirewallRule -Name FPS-ICMP4-ERQ-In ;
    get-netfirewallrule -Name WINRM-HTTP-In-TCP-PUBLIC | Set-NetFirewallRule -RemoteAddress Any ;
    Rename-Computer -NewName <%= $auto_name %> -Force ;
    iwr -Uri "http://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi" -OutFile ~/puppet-agent-x64-latest.msi ;
    cd ~ ;
    $MSIArguments = @(
        "/i"
        "$((Get-Location).Path)\puppet-agent-x64-latest.msi"
        "/qn"
        "/norestart"
        "PUPPET_AGENT_STARTUP_MODE=Disabled"
    )
    Start-Process "msiexec.exe" -Wait -ArgumentList $MSIArguments ;
    shutdown /r /t 60 ;
    </powershell>
    | EOW

  #Create the Linux target for teacher
  awskit::create_host { "${instance_name}-linux-teacher":
    ami             => $awskit::centos_ami,
    instance_type   => $instance_type_linux,
    user_data       => inline_epp($user_data_linux, { 'auto_name' => "${instance_name}-linux-teacher" }),
    security_groups => ["${facts['user']}-awskit-boltws"],
    key_name        => lookup('awskit::boltws_key_name'),
  }

  #Create the Windows target for teacher
  awskit::create_host { "${instance_name}-windows-teacher":
    ami             => $awskit::windows_ami,
    instance_type   => $instance_type_windows,
    user_data       => inline_epp($user_data_windows, { 'auto_name' => "${instance_name}-windows-teacher" }),
    security_groups => ["${facts['user']}-awskit-boltws"],
    key_name        => lookup('awskit::boltws_key_name'),
  }

  range(1,$count).each | $i | {
    #Create the Linux target
    awskit::create_host { "${instance_name}-linux-student${i}":
      ami             => $awskit::centos_ami,
      instance_type   => $instance_type_linux,
      user_data       => inline_epp($user_data_linux, { 'auto_name' => "${instance_name}-linux-student${i}" }),
      security_groups => ["${facts['user']}-awskit-boltws"],
      key_name        => lookup('awskit::boltws_key_name'),
    }

    #Create the Windows target
    awskit::create_host { "${instance_name}-windows-student${i}":
      ami             => $awskit::windows_ami,
      instance_type   => $instance_type_windows,
      user_data       => inline_epp($user_data_windows, { 'auto_name' => "${instance_name}-windows-student${i}" }),
      security_groups => ["${facts['user']}-awskit-boltws"],
      key_name        => lookup('awskit::boltws_key_name'),
    }
  }
}
