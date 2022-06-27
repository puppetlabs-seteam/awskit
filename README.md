# UPDATE!!!

This repository is no longer in use by the Puppet SE Team, and will be official Archived on Friday, July 1st. It will then be deleted on Friday, July 15th. If you are using any of the included code in any way, please take efforts to preserver your access to the code at your earlier convenience.

Thanks!  - The Puppetlabs SE Team


## Table of Contents

1. [Description](#description)
2. [Setup](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - class documentation](REFERENCE.md)
5. [Limitations - OS compatibility, etc.](#limitations)

## Description

This module helps deploying SE demo infrastructure in AWS in various regions.

It assumes a "Demo Reboot" Puppetmaster AMI is available in your region.

## Setup

### AWS setup

1. Make sure you have your AWS credentials (Access key and Secret key).
2. If you don't already have one, make sure you create an AWS SSH keypair in the region you are going to use.

(To create a keypair, go to <https://console.aws.amazon.com/ec2/v2/home#KeyPairs>)

### Setup on your Mac

Your Puppet agent needs to be version 6 or better

First, make sure you don't have rvm (Ruby Version Manager) enabled (see https://stackoverflow.com/questions/5660605/disable-rvm-or-use-ruby-which-was-installed-without-rvm).

```bash
xcode-select --install # install XCode build tools
brew install awscli
aws configure # needed for your AWS access
export AWS_REGION=$your_region # speeds up puppet aws module tremendously
export FACTER_aws_region=$your_region # needed for hiera
export FACTER_user=$your_user_name # needed for hiera
export FACTER_awskit_confdir=${HOME}/.awskit # to store your private hiera configuration
sudo /opt/puppetlabs/puppet/bin/gem install aws-sdk retries --no-ri --no-rdoc --verbose
puppet module install puppetlabs/aws
puppet module install puppetlabs/stdlib
```

### AWS bastion / role setup

If you have a bastion account and a role, the setup is a bit different.
You will need to configure 2 different _profiles_ in your aws configuration, namely the _bastion_ and the _tse_ profile.

First, configure your `bastion` profile with the bastion credentials:

```bash
aws configure --profile bastion
```

Next, configure your `tse` profile by adding the following to the file `~/.aws/config`:

```bash
[profile tse]
region = eu-west-2
role_arn = arn:aws:iam::221643363539:role/Engineer
source_profile = bastion
mfa_serial = arn:aws:iam::103716600232:mfa/$your_aws_IAM_user
```

After having done this, every time you open a shell to work with awskit, you first need to run this

```bash
source scripts/exportcreds.sh
```

(_Note_: this script needs `jq` to be installed: `brew install jq`)

This script will make sure you are properly logged in (it will ask your MFA token if needed) and it will initialise AWS environment variables with temporary credentials.

You can test whether the script actually provided correct credentials by doing:

1. `aws s3 ls`
2. `puppet resource s3_bucket`

Both commands 1 and 2 should display the list of s3 buckets in your TSE account.

### Docker setup
If you don't want install awskit on your local machine, you can spin up awskit in a Docker container.  The only machine pre-req is credentials and config need to exist on your Docker host.
```docker
docker run -it -d --name awskiter \
-e AWS_REGION=us-east-1 \
-e FACTER_aws_region=us-east-1 \
-e FACTER_user=abir \
-e FACTER_awskit_confdir=/root/.awskit \
-v ~/.aws/credentials:/root/.aws/credentials \
-v ~/.aws/config:/root/.aws/config \
-v ~/.awskit:/root/.awskit \
puppetseteam/puppet-aws-kit
```
Once the container is running, attach yourself to it.
```bash
docker exec -it awskiter bash
```
Once attached, you will need to run the exportcreds.sh script and paste in your MFA token.
```bash
[root@4ccfe43b55eb awskit]# source scripts/exportcreds.sh
Requesting identity with profile tse
Enter MFA code for arn:aws:iam::103716600232:mfa/abir:
{
    "Account": "221643373539",
    "UserId": "AROAJ3YUWJIC4P4HVYJO4:botocore-session-1558713181",
    "Arn": "arn:aws:sts::221644363539:assumed-role/Engineer/botocore-session-1558113181"
}
exporting AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN
Current token expires at: 2019-05-24T16:53:19Z
```
Now you're ready to use awskit!


## Usage

### Clone the awskit repo

```bash
git clone https://github.com/puppetlabs-seteam/awskit.git
```

### Configure hiera

The module uses module-level hiera to store all configuration. The hierarchy is expressed as follows in hiera.yaml:

```yaml
- name: "Private AWS region-level user data"
  datadir: "/%{::awskit_confdir}"
  path: "%{::aws_region}.yaml"

- name: "Private AWS common data"
  datadir: "/%{::awskit_confdir}"
  path: "common.yaml"

- name: "AWS region-level data"
  path: "%{::aws_region}/common.yaml"

- name: "Common data"
  path: "common.yaml"
```

- cd to the module dir `cd awskit`
- Configure region-specific AMI ids in the hash `awskit::amis` in the `data/common.yaml` file
- If not done yet, create the file `data/${FACTER_aws_region}/common.yaml` and configure
  region-specific AWS variables
- If not done yet, reserve a static IP for your master by doing:
  `aws ec2 allocate-address --region ${FACTER_aws_region} --domain vpc`
- Create the file `${FACTER_awskit_confdir}/${FACTER_aws_region}.yaml` and add
  your `awskit::key_name` and `awskit::master_ip`. This configuration is used in two ways:
  1. The master instance will get configured with that static IP
  2. The agent instances will connect to this IP as their master.
- Optionally add other static ip addresses to specific instances `${FACTER_awskit_confdir}/${FACTER_aws_region}.yaml` as follows:

```yaml
awskit::host_config:
  <instance-name>:
    public_ip: "<static ip>"
```

- Create the file `${FACTER_awskit_confdir}/common.yaml` and configure user-specific variabls (such as tags) which are valid across regions.

### Provision the master

- run `tasks/provision.sh master`

### Provision count linux agents

- run `tasks/provision.sh linux_node <count>`

### Provision count windows agents

- run `tasks/provision.sh windows_node <count>`

### Provision the Puppet Discovery VM

- run `tasks/provision.sh discovery`

### Provision the Windows Domain Controller

- run `tasks/provision.sh windc`

### Provision the WSUS server

- run `tasks/provision.sh wsus`

### Provision the CD4PE host

- run `tasks/provision.sh cd4pe`

### Provision the Gitlab host

- run `tasks/provision.sh gitlab`

### Provision the Docker host

- run `tasks/provision.sh dockerhost`

### Configure the control repo

Out of the box, the Puppetmasters come with a running Gitea git server with a demo control repo configured: https://github.com/puppetlabs-seteam/control-repo. You can clone this control repo to your local machine, customize it and push to Gitea. Alternatively, you can push a totally different control repo to Gitea.

For doing this, you will need to add your public key to Gitea to be able to push changes easily.

#### Add your public key to Gitea through the GUI

- Navigate to http://$master_ip:3000
- Click <somewhere> #TODO

#### Use bolt and a task to add your public key and push

First, make sure to install bolt.

Next run the following task on the local machine. This will push the contents of the control repo you specify to Puppetmaster's local Gitea server (which is hosted at http://$master_ip:3000). Optionally, you can add your own public key to Gitea so you can start pushing your changes to the PM directly.

Note:

- `public_key_name` can be any string - Gitea will register this public key under this name.
- `public_key_value` should contain your public key string

```bash
bolt task run awskit::conf_control_repo --modulepath .. -n $master_ip control_repo="${your_control_repo_url}" public_key_name=$FACTER_user public_key_value="$(cat ~/.ssh/id_rsa.pub)" -u root -p #--debug --verbose
```

After this, you can add a remote to your local control repo clone:

```bash
git clone ${your_control_repo_url}
cd ${your_control_repo}
git remote add awskit git@${master_ip}:puppet/control-repo.git
```

Now, you can push your changes directly to the master's Gitea server:

```bash
git commit -m "some commit"
git push awskit production
```

## Troubleshooting Tips
1. If you see a "Syntax error" at calculate_termination_date.pp it means you're running Puppet 5. You need Puppet 6. On your mac, run `brew cask install puppet-agent-6`
2. Make sure to create the [elastic ip](https://github.com/puppetlabs-seteam/awskit/tree/docker#configure-hiera) and VPC in AWS for the master and other requisite service before starting.
3. When in doubt run the provision task in debug mode. Read the [provision.sh](https://github.com/puppetlabs-seteam/awskit/blob/docker/tasks/provision.sh) for more details on how to turn that on.

## References

Please see [Class Documentation](REFERENCE.md)

## Limitations

Lots and lots.
Commit one.
Commit two.
Commit three.
