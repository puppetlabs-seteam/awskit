class devhops::join_domain {
  class { 'domain_membership':
    domain       => 'devhops.local',
    username     => lookup('devhops::join_domain_user'),
    password     => lookup('devhops::join_domain_password'),
    join_options => '3',
  }
}
