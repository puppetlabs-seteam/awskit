# devhops::create_discovery
#
# This class creates an instance in AWS for Puppet Discovery to be installed on
#
# @summary Installs AWS instance for Puppet Discovery installation
#
# @example
#   include devhops::create_discovery
class devhops::create_discovery (
  $centos_ami,
  $instance_type,
) {
}
