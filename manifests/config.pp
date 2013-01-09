# = Class: logstash::config
#
# This is the shared config class for the logstash module, override the sensible defaults as you see fit
#
# == Actions:
#
# Primarily a config class for logstash
#
# == Requires:
#
# Requirements. This could be packages that should be made available.
#
# == Sample Usage:
# redis_provider = package|external
#                  package  - we'll declare and ensure a redis package, using $redis_version
#                  external - assume redis is being installed outside of this module
# == Todo:
#
# * Update documentation
#
class logstash::config(
  $logstash_home                = $logstash::params::logstash_home,
  $logstash_etc                 = $logstash::params::logstash_etc,
  $logstash_log                 = $logstash::params::logstash_log,
  $logstash_jar_provider        = $logstash::params::logstash_jar_provider,
  $logstash_version             = $logstash::params::logstash_version,
  $logstash_verbose             = $logstash::params::logstash_verbose,
  $logstash_user                = $logstash::params::logstash_user,
  $logstash_group               = $logstash::params::logstash_group,
  $elasticsearch_provider       = $logstash::params::elasticsearch_provider,
  $elasticsearch_host           = $logstash::params::elasticsearch_host,
  $java_provider                = $logstash::params::java_provider,
  $java_package                 = $logstash::params::java_package,
  $java_home                    = $logstash::params::java_home
) inherits logstash::params {

  # just trying to make the fq variable a little less rediculous
  $user = $logstash_user
  $group = $logstash_group

  # create parent directory and all folders beneath it.
  file { $logstash_home:
    ensure   => 'directory',
  }
  file { "${logstash_home}/bin/":
    ensure  => 'directory',
    require => File[$logstash_home],
  }
  file { "${logstash_home}/lib/":
    ensure  => 'directory',
    require => File[$logstash_home],
  }
  file { $logstash_etc:
    ensure  => 'directory',
  }
  file { $logstash_log:
    ensure   => 'directory',
    recurse  => true,
  }

  # make sure we have a logstash jar (& dependencies, if we want)
  class { 'logstash::package':
    logstash_home     => $logstash_home,
    logstash_provider => $logstash_jar_provider,
    java_provider     => $java_provider,
    java_package      => $java_package,
  }

  # create the service user & group if required
  class { 'logstash::user':
    user        => $user,
    group       => $group,
    homeroot    => $logstash_home,
  }
}

