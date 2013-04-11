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
class logstash::service (
  $logstash_home              = $logstash::params::logstash_home,
  $logstash_etc               = $logstash::params::logstash_etc,
  $logstash_transport         = $logstash::params::logstash_transport,
  $logstash_verbose           = $logstash::params::logstash_verbose,
  $logstash_version           = $logstash::params::logstash_version,
  $logstash_web               = $logstash::params::logstash_web,
  $logstash_user              = $logstash::params::logstash_user,
  $logstash_group             = $logstash::params::logstash_group,
  $elasticsearch_provider     = $logstash::params::elasticsearch_provider,
  $java_home                  = $logstash::params::java_home,
  $xms_memory                 = $logstash::params::xms_memory,
  $xmx_memory                 = $logstash::params::xmx_memory,
) {

  Class['logstash::install'] -> Class['logstash::package'] -> Class['logstash::service']

  if ($logstash_web) {
    $add_args = " -- web --backend elasticsearch:///?local"
  } else {
    $add_args = ""
  }

  User  <| tag == 'logstash' |>
  Group <| tag == 'logstash' |>


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

