# = Class: logstash::package
#
# Class to manage where we get the logstash jar from
#
# == Parameters:
#
# $logstash_version::   description of parameter. default value if any.
# $logstash_provider::   description of parameter. default value if any.
# $logstash_home::   description of parameter. default value if any.
# $logstash_baseurl:: Where to curl the jar file from if http is used
# defaults to http://semicomplete.com/files/logstash/
# $java_package::   description of parameter. default value if any.
#
# == Actions:
#
# Makes sure that a logstash jar is available, via http, puppet or package
#
# == Requires:
#
# $logstash_provider='http' is the simplest and most tested method,
# it just curl's the file into place, so you need internet access,
# unless you have mirror'd the file locally
#
# == Sample Usage:
#
# == Todo:
#
# * Add better support for other ways providing the jar file?
#
class logstash::package(
  $logstash_home            = $logstash::params::logstash_home,
  $logstash_version         = $logstash::params::logstash_version,
  $logstash_provider        = $logstash::params::logstash_jar_provider,
  $logstash_baseurl         = $logstash::params::logstash_baseurl,
  $java_provider            = $logstash::params::java_provider,
  $java_package             = $logstash::params::java_package
) {
  Class['logstash::install'] -> Class['logstash::package']

  $logstash_jar = sprintf("%s-%s-%s", "logstash", $logstash_version, "monolithic.jar")
  $jar = "$logstash_home/$logstash_jar"

  # put the logstash jar somewhere
  # logstash_provider = package|puppet|http

  # if we're using a package as the logstash jar provider,
  # pull in the package we need
  if $logstash_provider == 'package' {
    # Obviously I abused fpm to create a logstash package and put it on my
    # repository
    package { 'logstash':
      ensure => 'latest',
    }
  }

  # You'll need to drop the jar in place on your puppetmaster
  # (puppetmaster file sharing isn't a great way to shift 50Mb+ files around)
  if $logstash_provider == 'puppet' {
    file { "$logstash_home/$logstash_jar":
      ensure => present,
      source => "puppet:///modules/logstash/$logstash_jar",
    }
  }

  if $logstash_provider == 'http' {
    $logstash_url = "$logstash_baseurl/$logstash_jar"

    package { 'curl': }

    # pull in the logstash jar over http
    exec { "curl -ko $logstash_home/$logstash_jar $logstash_url":
      timeout => 0,
      cwd     => "/tmp",
      creates => "$logstash_home/$logstash_jar",
      path    => ["/usr/bin", "/usr/sbin"],
      require => Package['curl'],
    }
  }

  if $logstash_provider == 'external' {
    notify { "It's up to you to provde $logstash_jar": }
  }

  # can't do anything without a java runtime, so we might as well
  # have a hook for pulling it in
  if $java_provider == 'package' {
    package { "$java_package": }
  }
}
