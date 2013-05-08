class logstash::params {
  $logstash_home                  = '/opt/logstash'
  $logstash_etc                   = ['/etc/logstash/','/etc/logstash/conf.d/'] #The trailing / is important (directory vs. file)
  $logstash_log                   = '/var/log/logstash'
  $logstash_transport             = 'amqp'
  $logstash_jar_provider          = 'package'
  $logstash_baseurl               = 'https://logstash.objects.dreamhost.com/release'
  $logstash_web                   = false
  $logstash_version               = '1.1.7'
  $logstash_verbose               = 'no'
  $logstash_user                  = 'logstash'
  $logstash_group                 = 'logstash'
  $elasticsearch_provider         = 'external'
  $elasticsearch_host             = '127.0.0.1'
  $redis_provider                 = 'package'
  $redis_package                  = 'redis'
  $redis_version                  = ''
  $redis_host                     = '127.0.0.1'
  $redis_port                     = '6379'
  $redis_key                      = 'logstash'
  $java_provider                  = 'package'
  $java_package                   = 'java-1.6.0-openjdk'
  $java_home                      = '/usr/lib/jvm/jre-1.6.0-openjdk.x86_64'
  $xms_memory                     = ''
  $xmx_memory                     = '256M'
  $enable                         = true

  # ensure
  $ensure = 'present'

  # autoupgrade
  $autoupgrade = false

  # service status
  $status = 'enabled'


  #### Defaults for other files

  # Config directory
  $configdir = '/etc/logstash/conf.d'


  #### Internal module values

  # packages
  case $::operatingsystem {
    'CentOS', 'Fedora', 'Scientific': {
      # main application
      $package = [ 'logstash' ]
    }
    'Debian', 'Ubuntu': {
      # main application
      $package = [ 'logstash' ]
    }
    default: {
      fail("\"${module_name}\" provides no package default value
            for \"${::operatingsystem}\"")
    }
  }

  # service parameters
  case $::operatingsystem {
    'CentOS', 'Fedora', 'Scientific': {
      $service_name       = 'logstash'
      $service_hasrestart = true
      $service_hasstatus  = true
      $service_pattern    = $service_name
    }
    'Debian', 'Ubuntu': {
      $service_name       = 'logstash'
      $service_hasrestart = true
      $service_hasstatus  = true
      $service_pattern    = $service_name
    }
    default: {
      fail("\"${module_name}\" provides no service parameters
            for \"${::operatingsystem}\"")
    }
  }
}
