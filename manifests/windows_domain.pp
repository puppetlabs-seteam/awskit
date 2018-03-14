# Class: devhops::windows_domain
# Builds a Windows domain controller and provisions AD resources
#
class devhops::windows_domain(
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

  dsc_xADDomain { 'DevHops Domain':
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
    dsc_xadorganizationalunit { 'OU_DevHops':
      dsc_ensure => 'Present',
      dsc_name   => 'DevHops',
      dsc_path   => $dn,
      require    => Dsc_xADDomain['DevHops Domain']
    }

    dsc_xaduser {'ADUser_DevHops1':
      dsc_ensure      => 'Present',
      dsc_domainname  => $domainname,
      dsc_username    => 'DevHops1',
      dsc_description => 'DevHops User 1',
      dsc_path        => join(['OU=DevHops', $dn],','),
      dsc_password    => {
        'user'     => 'DevHops1',
        'password' => Sensitive('PuppetD3vh0ps1!')
      },
      require         => Dsc_xadorganizationalunit['OU_DevHops'],
    }

    dsc_xadgroup { 'ADGroup_DevHopsers':
      dsc_ensure           => 'Present',
      dsc_groupname        => 'DevHopsers',
      dsc_path             => join(['OU=DevHops', $dn],','),
      dsc_memberstoinclude => 'DevHops1',
      require              => [
        Dsc_xadorganizationalunit['OU_DevHops'],
        Dsc_xaduser['ADUser_DevHops1']
      ]
    }
  }

}
