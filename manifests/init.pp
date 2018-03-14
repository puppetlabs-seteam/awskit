# devhops
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include devhops
class devhops(
  $key_name,
  $region,
  $vpc,
  $availability_zone,
  $subnet,
  $tags,
  $master_ip,
  $amis,
  ) {

    $pm_ami         = $amis[$region]['pm']
    $centos_ami     = $amis[$region]['centos']
    $windows_ami    = $amis[$region]['windows']
    $discovery_ami  = $amis[$region]['discovery']
    $windc_ami      = $amis[$region]['windc']
}
