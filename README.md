# devhops

#### Table of Contents

1. [Description](#description)
2. [Setup](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)

## Description

DevHops Workshops Infrastructure module

## Setup

First, make sure you have your AWS credentials (Access key and Secret key).

Next, install AWS pre-requisites:

```bash
brew install awscli
aws configure # needed for your AWS access
export AWS_REGION $your_region # speeds up puppet aws module tremendously
export FACTER_aws_region $your_region # needed for hiera
sudo /opt/puppetlabs/puppet/bin/gem install aws-sdk retries # needed by the aws module
puppet module install puppetlabs/aws
```

## Usage

### Provision the master

First, provision the master in your preferred region.
- cd to the module dir
- create the file `data/${your_region}.yaml`
- configure the aws variables in `data/$your_region.yaml`
- run `puppet apply -e 'include create_master' --modulepath ..`

### Provision the agents

- configure the aws variables in `data/$your_region.yaml`. Make sure to configure the number of windows and centos agents.
- run `puppet apply -e 'include create_agents' --modulepath ..`

## Limitations

The Puppetmaster AMI is not available in all regions yet.
