FROM centos:7

# Set up the paths for Ruby
ENV PATH=/opt/rh/rh-ruby24/root/usr/local/bin:/opt/rh/rh-ruby24/root/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=/opt/rh/rh-ruby24/root/usr/local/lib64:/opt/rh/rh-ruby24/root/usr/lib64:=/opt/rh/rh-ruby24/root/usr/local/lib64
ENV MANPATH=/opt/rh/rh-ruby24/root/usr/local/share/man:/opt/rh/rh-ruby24/root/usr/share/man:
ENV X_SCLS=rh-ruby24
ENV XDG_DATA_DIRS=/opt/rh/rh-ruby24/root/usr/local/share:/opt/rh/rh-ruby24/root/usr/share:/usr/local/share:/usr/share
ENV PKG_CONFIG_PATH=/opt/rh/rh-ruby24/root/usr/local/lib64/pkgconfig:/opt/rh/rh-ruby24/root/usr/lib64/pkgconfig

RUN yum -y update && mkdir -p /etc/tempest  

# install aws-cli
RUN yum -y install epel-release; yum clean all

RUN yum install -y java unzip which sudo groff
RUN cd /tmp; curl -O http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip; mkdir /usr/local/ec2; unzip ec2-api-tools.zip -d /usr/local/ec2
RUN cd /tmp; curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"; unzip awscli-bundle.zip; ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# Install latest PDK and image dependencies
RUN rpm -i https://pm.puppet.com/cgi-bin/pdk_download.cgi?arch=x86_64\&dist=el\&rel=7\&ver=latest \
      && yum makecache && yum install -y \
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

RUN rpm -Uvh https://yum.puppet.com/puppet6-release-el-7.noarch.rpm
RUN yum install -y puppet-bolt
COPY Puppetfile /root/.puppetlabs/bolt/Puppetfile
RUN bolt puppetfile install

#Set up Ruby 2.4. Must be separate from Ruby installed with PDK
RUN yum install -y centos-release-scl \
      && yum-config-manager --enable rhel-server-rhscl-7-rpms \
      && yum install -y rh-ruby24 rh-ruby24-ruby-devel

# Install dependent gems
RUN gem install --no-ri --no-rdoc  --verbose r10k \
      json \
      puppet:6.4.2 \
      rubocop \
      puppetlabs_spec_helper \
      puppet-lint \
      onceover \
      rest-client \
      ra10ke \
      aws-sdk \
      retries \
      && ln -s /usr/local/bundle/bin/* /usr/local/bin/

RUN puppet module install puppetlabs/aws --target-dir /etc/puppetlabs/code/modules
RUN puppet module install puppetlabs/stdlib --target-dir /etc/puppetlabs/code/modules
COPY Rakefile /Rakefile

RUN cd / && git clone -b docker https://github.com/puppetlabs-seteam/awskit.git

WORKDIR /awskit
