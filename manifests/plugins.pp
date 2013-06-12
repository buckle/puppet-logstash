class logstash::plugins (
  $pluginpath        = $logstash::params::logstash_home,
) {
  file { "${pluginpath}/logstash":
    ensure        => 'directory',
    source        =>  "puppet:///modules/${module_name}/plugins",
    recurse       => true,
  }
}
