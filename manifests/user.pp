# Class: logstash::user
#
# logstash_homeroot must be passed.
class logstash::user (
  $user                = $logstash::params::logstash_user,
  $group               = $logstash::params::logstash_group,
  $homeroot            = $logstash::params::logstash_homeroot
) {
  @user { $user:
    ensure     => present,
    comment     => 'logstash system account',
    uid         => '3300',
    home        => "${homeroot}/logstash",
    managehome => true,
    shell      => '/bin/false',
    system     => true,
    tag         => 'logstash',
  }

  @group { $group:
    ensure  => present,
    gid     => '3300',
    require => User[$user],
    tag     => 'logstash',
  }
}
