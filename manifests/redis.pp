# = Class: logstash::redis
#
# Manage installation & configuration of a redis server (to be used by logstash)
#
# == Parameters:
#
# $param::   description of parameter. default value if any.
#
# == Actions:
#
# Describe what this class does. What gets configured and how.
#
# == Requires:
#
# Requirements. This could be packages that should be made available.
#
# == Sample Usage:
#
# == Todo:
#
# * Update documentation
# * Add support for other ways providing redis?
#
class logstash::redis (
  $provider               = $logstash::params::redis_provider,
  $package                = $logstash::params::redis_package,
  $version                = $logstash::params::redis_version,
  $host                   = $logstash::params::redis_host,
  $port                   = $logstash::params::redis_port,
  $key                    = $logstash::params::redis_key,
) {

  if $provider == 'package' {

    # build a package-version if we need to
    $redis_package = $version ? {
      /\d+./    => $::operatingsystem ? {
        debian  => "${package}=${version}",
        default => "${package}-${version}"
      },
      default => $package,
    }

    package { $redis_package:
      ensure => present,
    }


    # operatingsystem specific file & service names
    case $::operatingsystem {
      centos, redhat, OEL: { $redis_conf = '/etc/redis.conf'
                        $redis_service = 'redis' }
      ubuntu, debian: { $redis_conf = '/etc/redis/redis.conf'
                        $redis_service = 'redis-server' }
      default: { fail("Unsupported operating system ($::operatingsystem)") }
    }

    # our redis config file
    file { $redis_conf:
      ensure  => present,
      content => template('logstash/redis.conf.erb'),
      require => Package[$redis_package],
    }

    # make sure the service is defined & running
    service { $redis_service:
      ensure    => 'running',
      hasstatus => true,
      enable    => true,
      subscribe => File[$redis_conf],
      require   => File[$redis_conf],
    }
  }
}
