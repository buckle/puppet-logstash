# = Class: logstash
#
# Manage installation & configuration of logstash.
# Everything is done in sub-classes.
# (lets call this the lazy monarch?)
#
# == Parameters:
#
# None.
#
# == Actions:
#
# None - all of the work is done by the 'public' sub-classes
#
# logstash::config
# logstash::indexer
# logstash::shipper
# logstash::web
#
# == Requires:
#
# working java implementation
#
# == Sample Usage:
#
# declare a config class:
#  class { 'logstash::config':
#    logstash_home         => '/opt/logstash',
#    logstash_jar_provider => 'http',
#    logstash_transport    => 'redis',
#    redis_provider        => 'package',
#  }
#
#  Then apply a worker class to a given node
#
#  node myindexer { class { 'logstash::indexer': } }
#  node ashippingnode { class { 'logstash::shipper': } }
#  node mywebbox { class { 'logstash::web': }
#
# == Todo:
#
# * Update documentation
# * add proper logstash config file fragment support
# * and lots more I'm sure.
#
class logstash (
  $logstash_home                = $logstash::params::logstash_home,
  $logstash_etc                 = $logstash::params::logstash_etc,
  $logstash_log                 = $logstash::params::logstash_log,
  $logstash_transport           = $logstash::params::logstash_transport,
  $logstash_jar_provider        = $logstash::params::logstash_jar_provider,
  $logstash_version             = $logstash::params::logstash_version,
  $logstash_verbose             = $logstash::params::logstash_verbose,
  $logstash_user                = $logstash::params::logstash_user,
  $logstash_group               = $logstash::params::logstash_group,
  $logstash_web                 = $logstash::params::logstash_web,
  $elasticsearch_provider       = $logstash::params::elasticsearch_provider,
  $elasticsearch_host           = $logstash::params::elasticsearch_host,
  $redis_provider               = $logstash::params::redis_provider,
  $redis_package                = $logstash::params::redis_package,
  $redis_version                = $logstash::params::redis_version,
  $redis_host                   = $logstash::params::redis_host,
  $redis_port                   = $logstash::params::redis_port,
  $redis_key                    = $logstash::params::redis_key,
  $java_provider                = $logstash::params::java_provider,
  $java_package                 = $logstash::params::java_package,
  $java_home                    = $logstash::params::java_home,
  $xms_memory                   = $logstash::params::xms_memory,
  $xmx_memory                   = $logstash::params::xmx_memory,
) inherits logstash::params {
  class { 'logstash::install':
    logstash_home                => $logstash_home,
    logstash_etc                 => $logstash_etc,
    logstash_log                 => $logstash_log,
    logstash_jar_provider        => $logstash_jar_provider,
    logstash_version             => $logstash_version,
    logstash_verbose             => $logstash_verbose,
    logstash_user                => $logstash_user,
    logstash_group               => $logstash_group,
    elasticsearch_provider       => $elasticsearch_provider,
    elasticsearch_host           => $elasticsearch_host,
    java_provider                => $java_provider,
    java_package                 => $java_package,
    java_home                    => $java_home
  } ->

  class { 'logstash::service':
    logstash_home               => $logstash_home,
    logstash_log                => $logstash_log,
    logstash_etc                => $logstash_etc,
    logstash_transport          => $logstash_transport,
    logstash_verbose            => $logstash_verbose,
    logstash_version            => $logstash_version,
    logstash_web                => $logstash_web,
    logstash_user               => $logstash_user,
    logstash_group              => $logstash_group,
    java_home                   => $java_home,
    xms_memory                  => $xms_memory,
    xmx_memory                  => $xmx_memory,
    elasticsearch_provider      => $elasticsearch_provider,
  } ->

  class { 'logstash::plugins':
    pluginpath              => $logstash_home,
  }

  if ($logstash_transport == 'redis') {
    class { 'logstash::redis':
      provider               => $logstash::params::redis_provider,
      package                => $logstash::params::redis_package,
      version                => $logstash::params::redis_version,
      host                   => $logstash::params::redis_host,
      port                   => $logstash::params::redis_port,
      key                    => $logstash::params::redis_key,
    }
  }
}
