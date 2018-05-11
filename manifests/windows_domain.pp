# Class: awskit::windows_domain
# Builds a Windows domain controller and provisions AD resources
#
class awskit::windows_domain(
  $dn,
  $localadminpw,
  $domainname,
  $domainnbname,
  $ntdspath,
  $safemodepw,
){

  # resources
  user {'Administrator':
    ensure   => present,
    password => Sensitive($localadminpw)
  }

  file { 'Active Directory NTDS':
    ensure => directory,
    path   => $ntdspath,
  }

  windowsfeature { 'Active Directory Domain Services':
    ensure                 => present,
    name                   => 'AD-Domain-Services',
    installmanagementtools => true,
  }

  dsc_xADDomain { 'awskit Domain':
    dsc_domainname                    => $domainname,
    dsc_domainadministratorcredential => {
      'user'     => 'Administrator',
      'password' => Sensitive($localadminpw)
    },
    dsc_safemodeadministratorpassword => {
      'user'     => 'safemode',
      'password' => Sensitive($safemodepw)
    },
    dsc_databasepath                  => $ntdspath,
    dsc_logpath                       => $ntdspath,
    require                           => [
      User['Administrator'],
      File['Active Directory NTDS'],
      Windowsfeature['Active Directory Domain Services']
    ]
  }

  reboot { 'dsc_reboot' :
    message => 'DSC has requested a reboot',
    when    => 'pending',
  }

  unless $facts['id'] =~ /^WORKGROUP\\/ {
    dsc_xadorganizationalunit { 'OU_awskit':
      dsc_ensure => 'Present',
      dsc_name   => 'awskit',
      dsc_path   => $dn,
      require    => Dsc_xADDomain['awskit Domain']
    }

    dsc_xaduser {'ADUser_awskit1':
      dsc_ensure      => 'Present',
      dsc_domainname  => $domainname,
      dsc_username    => 'awskit1',
      dsc_description => 'awskit User 1',
      dsc_path        => join(['OU=awskit', $dn],','),
      dsc_password    => {
        'user'     => 'awskit1',
        'password' => Sensitive('PuppetD3vh0ps1!')
      },
      require         => Dsc_xadorganizationalunit['OU_awskit'],
    }

    dsc_xadgroup { 'ADGroup_awskiters':
      dsc_ensure           => 'Present',
      dsc_groupname        => 'awskiters',
      dsc_path             => join(['OU=awskit', $dn],','),
      dsc_memberstoinclude => 'awskit1',
      require              => [
        Dsc_xadorganizationalunit['OU_awskit'],
        Dsc_xaduser['ADUser_awskit1']
      ]
    }
  }

}
