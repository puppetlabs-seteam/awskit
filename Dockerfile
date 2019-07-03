FROM centos:7

RUN yum -y update && mkdir -p /etc/tempest  

# install aws-cli
RUN yum -y install epel-release; yum clean all

RUN yum install -y java unzip which sudo groff
RUN cd /tmp; curl -O http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip; mkdir /usr/local/ec2; unzip ec2-api-tools.zip -d /usr/local/ec2
RUN cd /tmp; curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"; unzip awscli-bundle.zip; ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# Install useful tools
RUN yum install -y \
      git \
      vim \
      nano \
      make \
      gcc \
      gcc-c++ \
      autoconf \
      automake \
      patch \
      readline \
      readline-dev \
      zlib \
      zlib-devel \
      libffi-devel \
      libxml2-devel \
      openssl-devel \
      libgcc \
      bash \
      wget \
      jq \
      ca-certificates

# Install Bolt and Puppet Agent
RUN rpm -Uvh https://yum.puppet.com/puppet6-release-el-7.noarch.rpm
RUN yum install -y puppet-bolt
COPY Puppetfile /root/.puppetlabs/bolt/Puppetfile
RUN bolt puppetfile install
RUN bolt task run puppet_agent::install --nodes localhost

# Install dependent gems
RUN /opt/puppetlabs/puppet/bin/gem install --no-ri --no-rdoc --verbose aws-sdk retries
RUN /opt/puppetlabs/bolt/bin/gem install --no-ri --no-rdoc --verbose aws-sdk retries

# Install required modules
RUN /opt/puppetlabs/bin/puppet module install puppetlabs/aws --target-dir /etc/puppetlabs/code/modules
RUN /opt/puppetlabs/bin/puppet module install puppetlabs/stdlib --target-dir /etc/puppetlabs/code/modules

# Get latest version of AWSkit
RUN cd / && git clone -b docker https://github.com/puppetlabs-seteam/awskit.git

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
WORKDIR /awskit