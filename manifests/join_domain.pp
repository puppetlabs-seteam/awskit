# class to make a windows host join a AD domain
class awskit::join_domain {
  # this requires the following module to be set in the Puppetfile:
  # mod 'trlinkin/domain_membership', '1.1.2'
  # 
  class { 'domain_membership':
    domain       => lookup('awskit::windows_domain::name'),
    username     => lookup('awskit::windows_domain::join_user'),
    password     => lookup('awskit::windows_domain::join_password'),
    join_options => '3',
  }
}
