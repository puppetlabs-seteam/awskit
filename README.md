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

### Clone the devhops repo

```bash
git clone https://github.com/puppetlabs-seteam/devhops.git
```

### Configure hiera

- cd to the module dir `cd devhops`
- Configure region-specific AMI ids in the hash `devhops::amis` in the `data/common.yaml` file
- If not done yet, create the file `data/${FACTER_aws_region}/common.yaml` and configure
  region-specific AWS variables
- If not done yet, reserve a static IP for your master by doing:
  `aws ec2 allocate-address --region ${FACTER_aws_region}`
- Create the file `data/${FACTER_aws_region}/${FACTER_user}.yaml` and add
  your `devhops::key_name` and `devhops::master_ip`
- Create the file `data/${FACTER_user}.yaml` and configure user-specific variabls (such as tags)

### Provision the master

- run `puppet apply -e 'include devhops::create_master' --modulepath ..`

### Provision the agents

- run `puppet apply -e 'include devhops::create_agents' --modulepath ..`

### Provision the Puppet Discovery VM

- run `puppet apply -e 'include devhops::create_discovery' --modulepath ..`

## Limitations
