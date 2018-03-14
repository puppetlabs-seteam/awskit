class devhops::join_domain {
  # this requires the following module to be set in the Puppetfile:
  # mod 'trlinkin/domain_membership', '1.1.2'
  # 
  class { 'domain_membership':
    domain       => 'devhops.local',
    username     => lookup('devhops::join_domain_user'),
    password     => lookup('devhops::join_domain_password'),
    join_options => '3',
  }
}
