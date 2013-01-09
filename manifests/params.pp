class logstash::params {
  $logstash_home                  = '/opt/logstash'
  $logstash_etc                   = '/etc/logstash'
  $logstash_log                   = '/var/log/logstash'
  $logstash_transport             = 'amqp'
  $logstash_jar_provider          = 'package'
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

  $logstash_homeroot              = undef
}
