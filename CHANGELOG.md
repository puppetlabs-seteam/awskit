# Changelog

All notable changes to this project will be documented in this file.

## Release 0.3.0

**Features**

* added automatic user-specific naming for security groups and instances
  (configurable in hiera)
* added unit tests for the above 

## Release 0.2.2

**Features**

* added AMIs and default vpc data for us-east-1

## Release 0.2.1

**Features**

* many changes / fixes which didn't make it into CHANGELOG :-(
* added rspec tests
* now auto-configuring the IP address of the master instance from awskit::master_ip
* documented the awskit::hostconfig hash

## Release 0.2.0

**Features**

* added cd4pe class
* added create-azure-demo-host (warning: change parameters before using!)
* added create-gcp-demo-host (warning: change parameters before using!)

**Known Issues**

* tasks/provision.sh UX is awkward
* cloud provisioning demo manifests are not parametrized

## Release 0.1.0

Initial "release"