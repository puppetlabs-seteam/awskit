$base_name    = 'devhops'
$rg               = "${base_name}-rg-name"
$storage_account  = "${base_name}saccount"
$nsg              = "${base_name}-nsg"
$vnet             = "${base_name}-vnet"
$subnet           = "${base_name}-subnet"
$location         = 'uksouth'
$subscription_id = 'c82736ee-c108-452b-8178-f548c95d18fe'

# Base names for the vm's
$nic_base_name    = "${base_name}-nic"
$vm_base_name     = "${base_name}-vm"

# Re-use basic azure resources for the VMs
azure_resource_group { $rg:
  ensure              => present,
  parameters          => {},
  location            => $location
}

azure_storage_account { $storage_account:
  ensure              => present,
  parameters          => {},
  resource_group_name => $rg,
  account_name        => $storage_account,
  location            => $location,
  sku                 => {
    name => 'Standard_LRS',
    tier => 'Standard',
  }
}

azure_network_security_group { $nsg :
  ensure                      => present,
  parameters                  => {},
  resource_group_name         => $rg,
  location                    => $location,
  properties                  => {
  }
}

azure_virtual_network { $vnet:
  ensure              => 'present',
  parameters          => {},
  location            => $location,
  resource_group_name => $rg,
  properties          => {
    addressSpace => {
      addressPrefixes => ['10.0.0.0/24', '10.0.2.0/24']
    },
    dhcpOptions  => {
      dnsServers => ['8.8.8.8', '8.8.4.4']
    },
    subnets      => [
      {
        name       => $subnet,
        properties => {
          addressPrefix        => '10.0.0.0/24'
        }
      }]
  }
}

azure_subnet { $subnet:
  ensure               => present,
  subnet_parameters    => {},
  virtual_network_name => $vnet,
  resource_group_name  => $rg,
  properties           => {
    addressPrefix        => '10.0.0.0/24',
    networkSecurityGroup => {
      properties => {

      },
      id         => "/subscriptions/${subscription_id}/resourceGroups/${rg}/providers/Microsoft.Network/networkSecurityGroups/${nsg}"
    }
  }
}

# Create multiple NIC's and VM's

azure_network_interface { "${nic_base_name}-1":
  ensure              => present,
  parameters          => {},
  resource_group_name => $rg,
  location            => $location,
  properties          => {
    ipConfigurations => [{
      properties => {
        privateIPAllocationMethod => 'Dynamic',
        subnet                    => {
          id         =>
          "/subscriptions/${subscription_id}/resourceGroups/${rg}/providers/Microsoft.Network/virtualNetworks/${vnet}/subnets/${subnet}"
          ,
          properties => {
            addressPrefix     => '10.0.0.0/24',
            provisioningState => 'Succeeded'
          },
          name       => $subnet
        },
      },
      name       => "${base_name}-nic-ipconfig"
    }]
  }
}

azure_virtual_machine { "${vm_base_name}-1":
  ensure              => 'present',
  parameters          => {},
  location            => $location,
  resource_group_name => $rg,
  properties          => {
    hardwareProfile => {
        vmSize => 'Standard_D4s_v3'
    },
    storageProfile  => {
      imageReference => {
        publisher => 'canonical',
        offer     => 'UbuntuServer',
        sku       => '16.04.0-LTS',
        version   => 'latest'
      },
      osDisk         => {
        name         => "${vm_base_name}-1",
        createOption => 'FromImage',
        caching      => 'None',
        vhd          => {
          uri => "https://${$storage_account}.blob.core.windows.net/${vm_base_name}-1-container/${vm_base_name}-1.vhd"
        }
      },
      dataDisks      => []
    },
    osProfile       => {
      computerName       => "${vm_base_name}-1",
      adminUsername      => 'notAdmin',
      adminPassword      => 'P!!xxW00d',
      linuxConfiguration => {
        disablePasswordAuthentication => false
      }
    },
    networkProfile  => {
      networkInterfaces => [
        {
          id      => "/subscriptions/${subscription_id}/resourceGroups/${rg}/providers/Microsoft.Network/networkInterfaces/${nic_base_name}-1",
          primary => true
        }]
    },
  },
  type                => 'Microsoft.Compute/virtualMachines',
}


azure_network_interface { "${nic_base_name}-2":
  ensure                 => present,
  parameters             => {},
  resource_group_name    => $rg,
  location               => $location,
  properties             => {
    ipConfigurations => [{
      properties => {
        privateIPAllocationMethod => 'Dynamic',
        subnet                    => {
          id         =>
          "/subscriptions/${subscription_id}/resourceGroups/${rg}/providers/Microsoft.Network/virtualNetworks/${vnet}/subnets/${subnet}"
          ,
          properties => {
            addressPrefix     => '10.0.0.0/24',
            provisioningState => 'Succeeded'
          },
          name       => $subnet
        },
      },
      name       => "${base_name}-nic-ipconfig"
    }]
  }
}

azure_virtual_machine { "${vm_base_name}-2":
  ensure              => 'present',
  parameters          => {},
  location            => $location,
  resource_group_name => $rg,
  properties          => {
    hardwareProfile => {
        vmSize => 'Standard_D3_v2'
    },
    storageProfile  => {
      imageReference => {
        publisher => 'canonical',
        offer     => 'UbuntuServer',
        sku       => '16.04.0-LTS',
        version   => 'latest'
      },
      osDisk         => {
        name         => "${vm_base_name}-2",
        createOption => 'FromImage',
        caching      => 'None',
        vhd          => {
          uri => "https://${$storage_account}.blob.core.windows.net/${vm_base_name}-2-container/${vm_base_name}-2.vhd"
        }
      },
      dataDisks      => []
    },
    osProfile       => {
      computerName       => "${vm_base_name}-2",
      adminUsername      => 'notAdmin',
      adminPassword      => 'P!!xxW00d',
      linuxConfiguration => {
        disablePasswordAuthentication => false
      }
    },
    networkProfile  => {
      networkInterfaces => [
        {
          id      => "/subscriptions/${subscription_id}/resourceGroups/${rg}/providers/Microsoft.Network/networkInterfaces/${nic_base_name}-2",
          primary => true
        }]
    },
  },
  type                => 'Microsoft.Compute/virtualMachines',
}
