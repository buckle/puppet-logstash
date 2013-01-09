# = Class: logstash::server
#
# Description of logstash::server
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
#
class logstash::server (
  $logstash_home              = $logstash::params::logstash_home,
  $logstash_log               = $logstash::params::logstash_log,
  $logstash_etc               = $logstash::params::logstash_etc,
  $logstash_transport         = $logstash::params::logstash_transport,
  $logstash_verbose           = $logstash::params::logstash_verbose,
  $logstash_version           = $logstash::params::logstash_version,
  $logstash_web               = $logstash::params::logstash_web,
  $logstash_user              = $logstash::params::logstash_user,
  $logstash_group             = $logstash::params::logstash_group,
  $elasticsearch_provider     = $logstash::params::elasticsearch_provider,
  $java_home                  = $logstash::params::java_home
) {

  if ($logstash_web) {
    $add_args = " -- web --backend elasticsearch:///?local"
  } else {
    $add_args = ""
  }

  User  <| tag == 'logstash' |>
  Group <| tag == 'logstash' |>

  # create the config file based on the transport we are using
  # (this could also be extended to use different configs)
  case  $logstash_transport {
    /^redis$/: { $conf_content = template('logstash/indexer-input-redis.conf.erb',
                                                  'logstash/indexer-filter.conf.erb',
                                                  'logstash/indexer-output.conf.erb') }
    /^amqp$/:  { $conf_content = template('logstash/indexer-input-amqp.conf.erb',
                                                  'logstash/indexer-filter.conf.erb',
                                                  'logstash/indexer-output.conf.erb') }
    default:   { $conf_content = template('logstash/indexer-input-amqp.conf.erb',
                                                  'logstash/indexer-filter.conf.erb',
                                                  'logstash/indexer-output.conf.erb') }
  }

  file { "${logstash_etc}/logstash.conf":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $conf_content,
    notify  => Service['logstash-server'],
  }

  # if we're running with elasticsearch embedded, make sure the data dir exists
  if $elasticsearch_provider == 'embedded' {
    file { "${logstash_home}/data/elasticsearch":
      ensure => directory,
      owner  => $logstash_user,
      group  => $logstash_group,
      before => Service['logstash-server'],
      require => File["${logstash_home}/data"],
    }

    file { "${logstash_home}/data":
      ensure => directory,
      owner  => $logstash_user,
      group  => $logstash_group,
    }
  }
  file { '/etc/rc.d/init.d/logstash-server':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('logstash/logstash.init.erb'),
  }

  service { 'logstash-server':
    ensure    => 'running',
    hasstatus => true,
    enable    => true,
  }

}

