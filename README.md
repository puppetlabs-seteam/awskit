# devhops

## Table of Contents

1. [Description](#description)
2. [Setup](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)

## Description

This module helps deploying infrastructure for DevHops Workshops in various regions.

It assumes a "Demo Reboot" Puppetmaster AMI is available in your region.

The module uses module-level hiera to store all configuration. Global configuration goes into `data/common.yaml`, region-specific configuration lives in `data/${your_region}.yaml`.

## Setup

First, make sure you have your AWS credentials (Access key and Secret key).

Next, install AWS pre-requisites:

```bash
brew install awscli
aws configure # needed for your AWS access
export AWS_REGION=$your_region # speeds up puppet aws module tremendously
export FACTER_aws_region=$your_region # needed for hiera
export FACTER_user=$your_user_name # needed for hiera
sudo /opt/puppetlabs/puppet/bin/gem install aws-sdk retries
/opt/puppetlabs/puppet/bin/gem install aws-sdk retries #run again with sudo when on MacOS, ignore error messages
puppet module install puppetlabs/aws
puppet module install puppetlabs/stdlib
```

## Usage

### Clone the devhops repo to the same module folder as where you installed puppetlabs/aws & puppetlabs/stdlib

```bash
cd /Users/$(whoami)/.puppetlabs/etc/code/modules   #on MacOS, on Linux it would be /etc/puppetlabs/code/modules
git clone https://github.com/puppetlabs-seteam/devhops.git
```

### Provision the master

- cd to the module dir (cd devhops)
- create the file `data/${your_region}.yaml`
- reserve a static IP for the master by doing:
  `aws ec2 allocate-address --region ${your_region}`
- configure the aws variables in `data/${your_region}.yaml`, including the master IP
  Make sure to copy the devhops::tags value from common.yaml and configure accordingly for the region
- run `puppet apply -e 'include devhops::create_master' --modulepath ..`

### Provision the agents

- configure the aws variables in `data/${your_region}.yaml`. Make sure to configure the number of windows and centos agents.
- run `puppet apply -e 'include devhops::create_agents' --modulepath ..`

### Provision the Puppet Discovery VM

- configure the ami in `data/${your_region}.yaml`
- run `puppet apply -e 'include devhops::create_discovery' --modulepath ..`

## Limitations

The Puppetmaster AMI is only available in us-west-2 and eu-west-2 regions.
AMIs will become available in all relevant regions soon.
