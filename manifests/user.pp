# Class: logstash::user
#
# logstash_homeroot must be passed.
class logstash::user (
  $user                = $logstash::params::logstash_user,
  $group               = $logstash::params::logstash_group,
  $home                = $logstash::params::logstash_home
) {
  user { $user:
    ensure     => present,
    comment    => 'logstash system account',
    uid        => '3300',
    home       => $home,
    managehome => true,
    shell      => '/bin/false',
    system     => true,
  }

  group { $group:
    ensure  => present,
    gid     => '3300',
    require => User[$user],
  }
}
